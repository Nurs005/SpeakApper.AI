//
//  AuthViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var otpCode: String = ""
    @Published var isEmailSent: Bool = false
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var errorMessage: String?
    @Published var navigateToAuthCode: Bool = false
    @Published var navigateToAccountSettings: Bool = false
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    
    init(email: String = "") {
        self.email = email
    }
    
    func sendOTP(to email: String) async {
        print("Отправка OTP для: \(email)")
        
        guard !email.isEmpty else {
            self.errorMessage = "Введите email"
            return
        }
        
        isLoading = true
        
        do {
            let otp = String(Int.random(in: 100000...999999)) // Генерируем 6-значный код
            let expirationTime = Date().addingTimeInterval(300) // Код действует 5 минут
            
            // Сохраняем OTP в Firestore
            try await db.collection("otp_codes").document(email).setData([
                "email": email,
                "otp": otp,
                "timestamp": Timestamp(date: expirationTime)
            ])
            
            print("OTP \(otp) отправлен на \(email)")
            
            self.otpCode = otp
            self.isEmailSent = true
            
            DispatchQueue.main.async {
                self.navigateToAuthCode = true
            }
        } catch {
            self.errorMessage = "Ошибка отправки OTP: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    
    func verifyOTP(email: String, code: String) async {
        guard !code.isEmpty else {
            self.errorMessage = "Введите код"
            return
        }
        
        isLoading = true
        
        do {
            let snapshot = try await db.collection("otp_codes").document(email).getDocument()
            if let data = snapshot.data(),
               let storedOTP = data["otp"] as? String,
               storedOTP == code {
                
                // Код совпадает -> регистрируем пользователя в Firebase
                let authResult = try await Auth.auth().createUser(withEmail: email, password: UUID().uuidString)
                print("✅ Пользователь зарегистрирован: \(authResult.user.uid)")
                
                // Удаляем OTP после успешной верификации
                try await db.collection("otp_codes").document(email).delete()
                
                isLoggedIn = true
                UserDefaults.standard.set(email, forKey: "userEmail")
                navigateToAccountSettings = true
            } else {
                self.errorMessage = "Неверный код"
            }
        } catch {
            self.errorMessage = "Ошибка проверки OTP: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            email = ""
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            self.errorMessage = "Ошибка выхода: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "Ошибка: Пользователь не найден"
            return
        }
        
        isLoading = true
        
        do {
            let email = user.email ?? ""
            
            try await db.collection("users").document(user.uid).delete()
            try await db.collection("otp_codes").document(email).delete()
            try await user.delete()
            
            isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userEmail")
        } catch {
            self.errorMessage = "Ошибка удаления аккаунта: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
