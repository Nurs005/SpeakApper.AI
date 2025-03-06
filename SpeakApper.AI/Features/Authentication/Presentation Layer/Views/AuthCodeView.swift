//
//  AuthCodeView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI

struct AuthCodeView: View {
    @StateObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            contentBodyView
            NavigationLink(destination: SettingsView(), isActive: $authViewModel.navigateToAccountSettings) {
                EmptyView()
            }
            .hidden()
        }
    }
}


fileprivate extension AuthCodeView {
    var contentBodyView: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(alignment: .leading) {
                backButton
                title
                subtitle
                otpField
                continueButton
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(.white)
            .font(.system(size: 24))
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    var title: some View {
        Text("Проверьте электронную почту")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .padding(.bottom, 16)
    }
    
    var subtitle: some View {
        Text("Мы отправили письмо на адрес \(authViewModel.email). Перейдите по ссылке в письме или введите код. Срок действия кода истекает через 5 минут.")
            .font(.system(size: 16))
            .foregroundColor(.gray.opacity(0.7))
            .padding(.bottom, 16)
    }
    
    var otpField: some View {
        TextField("Код авторизации", text: $authViewModel.otpCode)
            .keyboardType(.numberPad)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
            .foregroundColor(.white)
            .padding(.bottom, 16)
    }
    
    
    var continueButton: some View {
        Button(action: {
            Task {
                await authViewModel.verifyOTP(email: authViewModel.email, code: authViewModel.otpCode)
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
        .disabled(authViewModel.otpCode.isEmpty)
        .opacity(authViewModel.otpCode.isEmpty ? 0.5 : 1.0)
    }
}




