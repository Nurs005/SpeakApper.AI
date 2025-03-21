//
//  AIIdeaView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct AIIdeaView: View {
    @Environment(Coordinator.self) var coordinator
    
    @State private var featureIdea: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @FocusState private var isInputActive: Bool
    
    @AppStorage("hasSeenRequestFeature") private var hasSeenRequestFeature = false
    @AppStorage("isRegistered") private var isRegistered = false
    
    @State private var showContactForm = false

    var body: some View {
        contentBodyView
            .onAppear {
                if !hasSeenRequestFeature {
                    hasSeenRequestFeature = true
                    if !isRegistered {
                        showContactForm = true
                    }
                }
            }
    }
}

// MARK: - UI Компоненты
fileprivate extension AIIdeaView {
    
    var contentBodyView: some View {
        VStack(spacing: 16) {
            headerView

            if showContactForm {
                contactDescriptionView
                contactForm
            } else {
                featureInputField
            }

            Spacer()
            actionButton
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#1B1A1A").edgesIgnoringSafeArea(.all))
        .onTapGesture { isInputActive = false }
    }

    var headerView: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            
            HStack {
                Spacer() 
                
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 4)
            }
            
            Text("Не хватает функции?\nПоделитесь своей идеей")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var contactDescriptionView: some View {
        Text("Хотите помочь сформировать будущее SpeakApper? Поделитесь своим именем и адресом электронной почты, чтобы получить приглашение предоставить отзыв о новых функциях.")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var featureInputField: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                .background(Color.clear)
                .cornerRadius(12)

            if featureIdea.isEmpty {
                Text("Опишите функцию, которую вы хотели бы использовать")
                    .foregroundColor(.gray)
                    .padding(.top, 12)
                    .padding(.leading, 12)
            }

            TextEditor(text: $featureIdea)
                .focused($isInputActive)
                .padding(12)
                .foregroundColor(.white)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
        }
        .frame(height: 160)
    }

    var contactForm: some View {
        VStack(spacing: 12) {
            CustomTextField(placeholder: "Имя", text: $name)
            CustomTextField(placeholder: "Электронная почта", text: $email, keyboardType: .emailAddress)
        }
    }

    var actionButton: some View {
        Button(action: {
            if showContactForm {
                isRegistered = true
            } else {
                showContactForm = true
            }
        }) {
            Text(showContactForm ? "Отправить" : "Запросить функцию")
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isButtonDisabled ? Color(hex: "#6F7CFF").opacity(0.4) : Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(isButtonDisabled)
        .padding(.bottom, 24)
    }
    
    var isButtonDisabled: Bool {
        showContactForm
            ? name.isEmpty || email.isEmpty
            : featureIdea.isEmpty
    }
}

// MARK: - Кастомное текстовое поле
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                .background(Color.clear)
                .cornerRadius(12)

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.top, 12)
                    .padding(.leading, 12)
            }

            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding(12)
                .foregroundColor(.white)
                .background(Color.clear)
        }
        .frame(height: 50)
    }
}



//TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
