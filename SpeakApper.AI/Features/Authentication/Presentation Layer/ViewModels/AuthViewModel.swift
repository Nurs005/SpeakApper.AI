//
//  AuthViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import Foundation
import FirebaseAuth
import Firebase
import Combine
import AuthenticationServices
import CryptoKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var otpCode: String = ""
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var currentNonce: String?

    init() {
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }

    // MARK: - Проверка состояния аутентификации
    func checkAuthState() {
        self.isLoggedIn = Auth.auth().currentUser != nil
    }

    // MARK: - Отправка OTP-кода
    func sendOTP(to email: String) async -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Введите email"
            return false
        }

        do {
            let otp = String(Int.random(in: 100000...999999))
            let expirationTime = Date().addingTimeInterval(300)

            try await db.collection("otp_codes").document(email).setData([
                "email": email,
                "otp": otp,
                "timestamp": Timestamp(date: expirationTime)
            ])

            print("OTP \(otp) отправлен на \(email)")
            self.email = email
            self.otpCode = otp 
            UserDefaults.standard.set(email, forKey: "userEmail")
            return true
        } catch {
            self.errorMessage = "Ошибка отправки OTP: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Подтверждение OTP-кода
    func verifyOTP(email: String, code: String) async -> Bool {
        guard !email.isEmpty, !code.isEmpty else {
            errorMessage = "Введите email и код"
            return false
        }

        isLoading = true

        do {
            let snapshot = try await db.collection("otp_codes").document(email).getDocument()

            if let data = snapshot.data(),
               let storedOTP = data["otp"] as? String,
               storedOTP == code {

                let authResult = try await Auth.auth().createUser(withEmail: email, password: UUID().uuidString)
                print("Пользователь зарегистрирован: \(authResult.user.uid)")

                try await db.collection("otp_codes").document(email).delete()

                self.isLoggedIn = true
                self.email = email
                UserDefaults.standard.set(email, forKey: "userEmail")
                return true
            } else {
                self.errorMessage = "Неверный код"
                return false
            }
        } catch {
            self.errorMessage = "Ошибка проверки OTP: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Вход через Apple ID
    func signInWithApple(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        self.currentNonce = nonce
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce,
                      let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    errorMessage = "Ошибка получения токена Apple"
                    return
                }

                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)

                do {
                    let authResult = try await Auth.auth().signIn(with: credential)
                    self.email = authResult.user.email ?? ""
                    self.isLoggedIn = true
                    UserDefaults.standard.set(self.email, forKey: "userEmail")
                } catch {
                    errorMessage = "Ошибка входа через Apple ID: \(error.localizedDescription)"
                }
            }
        case .failure(let error):
            errorMessage = "Ошибка авторизации через Apple: \(error.localizedDescription)"
        }
    }

    // MARK: - Выход из системы
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.email = ""
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            self.errorMessage = "Ошибка выхода: \(error.localizedDescription)"
        }
    }

    // MARK: - Удаление аккаунта
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Ошибка: Пользователь не найден"
            return
        }

        print("Удаление аккаунта для пользователя: \(user.email ?? "неизвестный email")")

        do {
            let email = user.email ?? ""

            // Удаление данных из Firestore
            try await db.collection("users").document(user.uid).delete()
            try await db.collection("otp_codes").document(email).delete()

            // Удаление аккаунта из Firebase Auth
            try await user.delete()
            print("Аккаунт удалён")

            self.isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            self.errorMessage = "Ошибка удаления аккаунта: \(error.localizedDescription)"
        }
    }

    // MARK: - Генерация Nonce для Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Ошибка генерации nonce")
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
