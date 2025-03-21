//
//  DeleteAccountSurveyView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 12.03.2025.
//

import SwiftUI

struct DeleteAccountSurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedReason: String? = nil
    @State private var showFinalAlert = false

    let reasons = [
        "Возникли проблемы с оплатой",
        "Ненадежный или глючный",
        "Использование альтернативного приложения",
        "Слишком дорого",
        "Не использую его",
        "Приложение сложно использовать",
        "Отсутствие функциональности",
        "Другое"
    ]
    
    var body: some View {
        VStack {
            closeButton
            titleView
            reasonListView
            continueButton
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .overlay(showFinalAlert ? customFinalAlert() : nil)
    }
}

// MARK: - UI Components
private extension DeleteAccountSurveyView {
    // Кнопка закрытия
    var closeButton: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // Заголовок
    var titleView: some View {
        Text("Выберите основную причину удаления вашего аккаунта")
            .font(.system(size: 21))
            .foregroundColor(.white)
            .bold()
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.top, 10)
    }

    // Список причин удаления
    var reasonListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(reasons, id: \.self) { reason in
                    HStack {
                        Text(reason)
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { self.selectedReason == reason },
                            set: { if $0 { self.selectedReason = reason } else { self.selectedReason = nil } }
                        ))
                        .labelsHidden()
                        .toggleStyle(RadioButtonToggleStyle())
                    }
                    .padding()
                   // .background(Color("listColor"))
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation {
                            selectedReason = reason
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // Кнопка "Продолжить удаление"
    var continueButton: some View {
        Button(action: {
            withAnimation {
                showFinalAlert = true
            }
        }) {
            Text("Продолжить удаление")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedReason == nil ? Color(hex: "#FFD7D7").opacity(0.5) : Color(hex: "#FFD7D7"))
                .foregroundColor(.red)
                .cornerRadius(10)
        }
        .disabled(selectedReason == nil)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

// MARK: - Кастомный Alert
private extension DeleteAccountSurveyView {
    func customFinalAlert() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Спасибо за ваш отзыв!")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Text("Мы можем помочь решить эту проблему. Пожалуйста, свяжитесь с нашей службой поддержки и предоставьте более подробную информацию.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                supportButton
                deleteButton
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
    
    // Кнопка "Связаться со службой поддержки"
    var supportButton: some View {
        Button(action: {
            print("Связаться с поддержкой")
        }) {
            Text("Связаться со службой поддержки")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
    
    // Кнопка "Удалить аккаунт"
    var deleteButton: some View {
        Button(action: {
            deleteAccount()
        }) {
            Text("Удалить аккаунт")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
               // .frame(height: 50)
                .foregroundColor(.red)
                
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Логика удаления аккаунта
private extension DeleteAccountSurveyView {
    func deleteAccount() {
        print("Аккаунт удалён по причине: \(selectedReason ?? "")")
        Task {
            await authViewModel.deleteAccount()
            authViewModel.isLoggedIn = false
            presentationMode.wrappedValue.dismiss() 
        }
    }
}

// MARK: - Кастомный стиль для радио-кнопки
struct RadioButtonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(configuration.isOn ? Color(hex: "#6F7CFF") : .gray, lineWidth: 3)
                .frame(width: 24, height: 24)
            
            if configuration.isOn {
                Circle()
                    .fill(Color(hex: "#6F7CFF"))
                    .frame(width: 12, height: 12)
            }
        }
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
            }
        }
        .animation(.easeInOut, value: configuration.isOn)
    }
}
