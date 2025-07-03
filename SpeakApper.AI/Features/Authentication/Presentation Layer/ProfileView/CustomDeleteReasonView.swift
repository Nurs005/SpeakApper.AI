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
                subject: "Account deletion reason (Other)",
                messageBody: reasonText.isEmpty ? "User did not specify a reason." : reasonText,
                isHTML: false
            )
        }
        .alert("Could not send email", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .presentationDetents([.fraction(0.45)])
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Another reason? We'd love your feedback!")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))

            Text("Share your reason with us so we can learn and improve.")
                .foregroundColor(.gray)
                .font(.system(size: 14))

            Divider().background(Color.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if reasonText.isEmpty {
                Text("Reason for deleting account")
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
            Text("Submit")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(reasonText.isEmpty ? Color.gray.opacity(0.3) : Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(reasonText.isEmpty)
    }
}
