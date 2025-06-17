//
//  AccountSettingsView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.02.2025.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(Coordinator.self) var coordinator
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showLogoutAlert = false
    @State private var showDeleteSurvey = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 16) {
                backButton
                title
                accountInfo
                signInWithApple
                settingsForm
                Spacer()
            }
            .navigationBarBackButtonHidden()
        }
        .overlay(
            showLogoutAlert ? customLogoutAlert() : nil
        )
    }
}

// MARK: - UI Components
private extension AccountSettingsView {
    var backButton: some View {
        HStack {
            Button(action: { coordinator.pop() }) {
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
    
    var title: some View {
        Text("Настройки аккаунта")
            .font(.system(size: 28).bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
    
    var accountInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(authViewModel.email)
                .font(.system(size: 17))
                .foregroundColor(.white)
            Text("Ваш адрес электронной почты")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
    
    var signInWithApple: some View {
        HStack(spacing: 8) {
            Image(systemName: "applelogo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
            Text("Войти через Apple")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            Image(systemName: "trash")
                .foregroundColor(.white)
            Text("Удалить аккаунт")
                .foregroundColor(.white)
                .font(.system(size: 17))
            Spacer()
            Button(action: {
                showDeleteSurvey = true
            }) {
                Text("Удалить")
                    .foregroundColor(.red)
                    .font(.system(size: 17))
            }
        }
        .listRowBackground(Color("listColor"))
        .sheet(isPresented: $showDeleteSurvey) {
            DeleteAccountSurveyView()
        }
    }
    
    var logoutButton: some View {
        HStack {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundColor(.white)
            Text("Выйти")
                .foregroundColor(.white)
                .font(.system(size: 17))
            Spacer()
        }
        .onTapGesture {
            showLogoutAlert = true 
        }
        .listRowBackground(Color("listColor"))
    }
    
    // MARK: - Кастомный Alert
    func customLogoutAlert() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                // Заголовок
                Text("Выйти?")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Описание
                Text("Точно хотите выйти? Существующие записи будут удалены с этого устройства, но они по-прежнему доступны в вашем аккаунте. Чтобы получить к ним доступ, просто войдите в аккаунт.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Кнопки
                HStack {
                    Button(action: {
                        authViewModel.signOut()
                        coordinator.popToRoot()
                        showLogoutAlert = false
                    }) {
                        Text("Выйти")
                            .font(.system(size: 17))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.clear)
                            .foregroundColor(Color("ButtonColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("ButtonColor"), lineWidth: 2)
                            )
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showLogoutAlert = false
                    }) {
                        Text("Отмена")
                            .font(.system(size: 17))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("ButtonColor"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "#1B1A1A"))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
    }
}
