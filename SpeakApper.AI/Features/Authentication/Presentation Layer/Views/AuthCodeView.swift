//
//  AuthCodeView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI

struct AuthCodeView: View {
    let email: String
    @StateObject var authViewModel: AuthViewModel
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        contentBodyView
    }
}

private extension AuthCodeView {
    var contentBodyView: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(alignment: .leading) {
                backButton
                    .padding(.bottom, 16)
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
            .navigationBarBackButtonHidden()
            .padding(.horizontal, 16)
        }
    }
    
    var backButton: some View {
        Button(action: {
            coordinator.push(.login)
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .padding(.top, 10)
    }

    
    var title: some View {
        Text("Check your email")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .padding(.bottom, 16)
    }
    
    var subtitle: some View {
        Text("We sent an email to \(email). Follow the link or enter the code. The code expires in 5 minutes.")
            .font(.system(size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray)
            .padding(.bottom, 16)
    }
    
    var otpField: some View {
        TextField("", text: $authViewModel.otpCode, prompt: Text("Verification code").foregroundColor(.white))
            .keyboardType(.numberPad)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
            .foregroundColor(.white)
            .padding(.bottom, 16)
    }
    
    var continueButton: some View {
        Button(action: {
            Task {
                let success = await authViewModel.verifyOTP(email: email, code: authViewModel.otpCode)
                if success {
                    coordinator.popToRoot()
                    coordinator.push(.settings)
                }
            }
        }) {
            Text("Continue")
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
