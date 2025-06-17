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
    static let shared = AuthViewModel()
    @Published var email: String = ""
    @Published var otpCode: String = ""
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isAccountDeleted: Bool = false
    
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
        
        guard let url = URL(string: "https://mystical-height-454513-u4.uc.r.appspot.com/v1/gateway/otp") else {
            errorMessage = "Неверный URL"
            return false
        }
        
        let otp = String(Int.random(in: 100000...999999))
        let expirationTime = Date().addingTimeInterval(300)
        
        do {
            // Сохраняем OTP в Firestore
            try await db.collection("otp_users").document(email).setData([
                "email": email,
                "otp": otp,
                "timestamp": Timestamp(date: expirationTime)
            ])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "email": email,
                "otp": otp
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("OTP отправлен на \(email)")
                return true
            } else {
                let responseString = String(data: data, encoding: .utf8) ?? "Нет ответа"
                errorMessage = "Ошибка отправки: \(responseString)"
                print("Ошибка ответа: \(responseString)")
                return false
            }
        } catch {
            errorMessage = "Ошибка отправки OTP: \(error.localizedDescription)"
            print("Ошибка запроса: \(error.localizedDescription)")
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
            let snapshot = try await db.collection("otp_users").document(email).getDocument()
            
            guard let data = snapshot.data(),
                  let storedOTP = data["otp"] as? String else {
                errorMessage = "Код не найден. Запросите новый."
                return false
            }
            
            guard storedOTP == code else {
                errorMessage = "Неверный код"
                return false
            }
            
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: UUID().uuidString)
                print("Пользователь зарегистрирован: \(authResult.user.uid)")
                
                try await db.collection("otp_users").document(email).delete()
                
                self.email = email
                self.isLoggedIn = true
                UserDefaults.standard.set(email, forKey: "userEmail")
                return true
                
            } catch {
                self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
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
            await MainActor.run {
                self.errorMessage = "Ошибка: Пользователь не найден"
            }
            return
        }
        
        do {
            let email = user.email ?? ""
            
            try await db.collection("users").document(user.uid).delete()
            try await db.collection("otp_users").document(email).delete()
            try await user.delete()
            
            print("Аккаунт удалён")
            
            await MainActor.run {
                self.isLoggedIn = false
                self.isAccountDeleted = true
                self.clearLocalData()
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка удаления аккаунта: \(error.localizedDescription)"
            }
        }
    }
    
    private func clearLocalData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
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
