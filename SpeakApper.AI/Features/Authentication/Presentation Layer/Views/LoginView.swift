//
//  LoginView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                contentBodyView
            }
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
             //   continueButton
                separator
                appleSignInButton
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var backButton: some View {
        Button(action: { dismiss() }) {
            HStack { Image(systemName: "chevron.left") }
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
    
//    var continueButton: some View {
//        NavigationLink(destination: NavigationDestination.authCode(email: email)) {
//            Text("Продолжить")
//                .font(.headline)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color("ButtonColor"))
//                .cornerRadius(10)
//        }
//        .simultaneousGesture(TapGesture().onEnded {
//            guard !email.isEmpty else { return }
//            authViewModel.email = email
//            Task {
//                await authViewModel.sendOTP(to: email)
//            }
//        })
//        .disabled(email.isEmpty)
//        .opacity(email.isEmpty ? 0.5 : 1.0)
//    }

    
    
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
        Button(action: {
            // Действие при нажатии через Apple ID
        }) {
            HStack {
                Image(systemName: "applelogo")
                    .font(.headline)
                Text("Продолжить с Apple")
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}
