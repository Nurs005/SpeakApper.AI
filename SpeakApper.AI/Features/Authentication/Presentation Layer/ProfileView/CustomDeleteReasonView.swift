//
//  CustomDeleteReasonView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 30.03.2025.
//

import SwiftUI
import MessageUI

struct CustomDeleteReasonView: View {
    @Environment(Coordinator.self) var coordinator
    @State private var reasonText: String = ""
    @State private var showMailView = false
    @State private var showAlert = false
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            Color(hex: "#252528").ignoresSafeArea()

            VStack(spacing: 16) {
                titleBlock
                textEditor
                saveButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTextFocused = true
            }
        }
        .sheet(isPresented: $showMailView) {
            SendMailView(
                recipients: ["support@speakapper.com"],
                subject: "Причина удаления аккаунта (Другое)",
                messageBody: reasonText.isEmpty ? "Пользователь не указал причину." : reasonText,
                isHTML: false
            )
        }
        .alert("Не удалось отправить письмо", isPresented: $showAlert) {
            Button("Ок", role: .cancel) {}
        }
        .presentationDetents([.fraction(0.45)])
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Есть еще причина? Мы будем рады вашим отзывам!")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))

            Text("Поделитесь с нами своей причиной, чтобы мы могли учиться и совершенствоваться.")
                .foregroundColor(.gray)
                .font(.system(size: 14))

            Divider().background(Color.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if reasonText.isEmpty {
                Text("Причина удаления аккаунта")
                    .foregroundColor(.gray)
                    .padding(.top, 12)
                    .padding(.leading, 12)
            }

            TextEditor(text: $reasonText)
                .focused($isTextFocused)
                .transparentScrolling()
                .padding(.leading, 10)
                .foregroundColor(.white)
        }
    }

    private var saveButton: some View {
        Button(action: {
            if MFMailComposeViewController.canSendMail() {
                showMailView = true
            } else {
                showAlert = true
            }
        }) {
            Text("Сохранять")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(reasonText.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(reasonText.isEmpty)
    }
}
