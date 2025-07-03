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
                Text("Back")
            }
            .foregroundColor(.white)
            .font(.system(size: 17))
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 10)
    }
    
    var title: some View {
        Text("Account settings")
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
            Text("Your email address")
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
            Text("Sign in with Apple")
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    var settingsForm: some View {
        Form {
            Section(header: Text("Other").foregroundColor(.gray)) {
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
            Text("Delete account")
                .foregroundColor(.white)
                .font(.system(size: 17))
            Spacer()
            Button(action: {
                showDeleteSurvey = true
            }) {
                Text("Delete")
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
            Text("Log Out")
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
                Text("Log out?")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Описание
                Text("Are you sure you want to log out? Existing recordings will be removed from this device but remain in your account. To access them again, simply log in.")
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
                        Text("Log Out")
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
                        Text("Cancel")
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
