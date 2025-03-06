//
//  AccountSettingsView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack(spacing: 16) {
                    backButton
                    accountInfo
                    signInWithApple
                    settingsForm
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - UI Components
private extension AccountSettingsView {
    var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                Text("Назад")
            }
            .foregroundColor(.white)
            .font(.system(size: 17))
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 10)
    }

    var accountInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(authViewModel.email)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            Text("Ваш адрес электронной почты")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
    }

    var signInWithApple: some View {
        HStack {
            Image(systemName: "applelogo")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text("Войти через Apple")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.leading, 16)
    }

    var settingsForm: some View {
        Form {
            Section(header: Text("Другое").foregroundColor(.gray)) {
                deleteAccountButton
                logoutButton
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundColor"))
        .listRowBackground(Color("listColor"))
    }

    var deleteAccountButton: some View {
        HStack {
            SectionView(iconName: "delete-outline-rounded", title: "Удалить аккаунт")
            Spacer()
            Button(action: {
                Task {
                    await authViewModel.deleteAccount()
                    authViewModel.isLoggedIn = false
                    dismiss()
                }
            }) {
                Text("Удалить")
                    .foregroundColor(.red)
                    .font(.system(size: 17))
            }
        }
    }

    var logoutButton: some View {
        Button(action: {
            authViewModel.signOut()
            dismiss()
        }) {
            SectionView(iconName: "logout", title: "Выйти")
        }
    }
}
