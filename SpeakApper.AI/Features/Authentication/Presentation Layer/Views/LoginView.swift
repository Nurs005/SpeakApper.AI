//
//  LoginView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit

struct LoginView: View {
    @Environment(Coordinator.self) var coordinator
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            contentBodyView
        }
    }
}

fileprivate extension LoginView {
    var contentBodyView: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                backButton
                title
                subtitle
                emailField
                continueButton
                separator
                appleSignInButton
                Spacer()
            }
            .alert(errorMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var backButton: some View {
        Button(action: { coordinator.pop() }) {
            HStack {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(.white)
            .font(.system(size: 24))
        }
        .padding(.top, 10)
    }

    var title: some View {
        Text("Войдите в SpeakApper")
            .font(.system(size: 21).weight(.bold))
            .foregroundColor(.white)
            .padding(.top, 16)
    }

    var subtitle: some View {
        Text("Храните файлы в безопасности и синхронизируйте их на всех устройствах")
            .font(.system(size: 16))
            .multilineTextAlignment(.leading)
            .foregroundColor(.gray)
            .padding(.bottom, 16)
    }

    var emailField: some View {
        TextField("", text: $email, prompt: Text("Ваш адрес эл. почты").foregroundColor(.white))
            .padding()
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
            .foregroundStyle(.white)
            .padding(.bottom, 16)
    }

    var continueButton: some View {
        Button(action: {
            guard !email.isEmpty else { return }
            
            Task {
                if await authViewModel.sendOTP(to: email) {
                    authViewModel.email = email
                    coordinator.push(.authCode(email: email))
                }
            }
        }) {
            Text("Продолжить")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("ButtonColor"))
                .cornerRadius(10)
        }
        .disabled(email.isEmpty)
        .opacity(email.isEmpty ? 0.5 : 1.0)
    }

    var separator: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
            Text("ИЛИ")
                .foregroundColor(.white)
                .font(.system(size: 14))
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 16)
    }

    var appleSignInButton: some View {
          SignInWithAppleButton(.signIn) { request in
              authViewModel.signInWithApple(request: request)
          } onCompletion: { result in
              Task {
                  await authViewModel.handleAppleSignIn(result: result)
                  if authViewModel.isLoggedIn {
                      coordinator.push(.main)
                  }
              }
          }
          .frame(height: 56)
          .cornerRadius(10)
      }
  }
