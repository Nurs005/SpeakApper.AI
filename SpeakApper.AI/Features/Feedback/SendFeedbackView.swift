//
//  SendFeedbackView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 11.03.2025.
//

import SwiftUI
import MessageUI

struct SendFeedbackView: View {
    @Environment(Coordinator.self) var coordinator
    @ObservedObject var viewModel: SettingsViewModel
    @State private var feedbackText: String = "Hi, SpeakApp Team!\n\nHere are my thoughts about my SpeakApp experience."
    @State private var showMailView = false
    @State private var mailErrorAlert = false

    // Данные из Info.plist
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    
    private let iosVersion = UIDevice.current.systemVersion
    private let deviceModel = UIDevice.current.localizedModel
    private let deviceName = UIDevice.current.name
    private let uid = UUID().uuidString
    
    var body: some View {
        ZStack {
            Color(hex: "#252528").ignoresSafeArea()
            
            VStack(spacing: 16) {
                headerView
                contentBodyView
            }
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 16)
        }
        .sheet(isPresented: $showMailView) {
            SendMailView(
                recipients: ["support@speakapper.com"],
                subject: "SpeakApp iOS v\(appVersion) (\(buildNumber)) feedback",
                messageBody: """
                \(feedbackText)

                App version: v\(appVersion) (\(buildNumber))
                iOS version: \(iosVersion)
                Device: \(deviceName)
                UID: \(uid)
                Source: settings
                От: \(viewModel.email.isEmpty ? "Гость" : viewModel.email)
                Отправлено с iPhone
                """,
                isHTML: false
            )
        }
        .alert("Не удалось отправить письмо", isPresented: $mailErrorAlert) {
            Button("Ок", role: .cancel) {}
        }
    }
}

// MARK: - UI Компоненты
fileprivate extension SendFeedbackView {
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Text("Отменить")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                Spacer()
            }
            
            HStack(spacing: 8) {
                Text("SpeakApp iOS v\(appVersion) (\(buildNumber)) feedback")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(.white)
                
                Button(action: {
                    sendFeedback()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var contentBodyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Кому: support@speakapper.com")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Divider().background(Color.white.opacity(0.2))
            
            Text("Копия/Скрытая копия; От: \(viewModel.email.isEmpty ? "Гость" : viewModel.email)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Divider().background(Color.white.opacity(0.2))
            
            Text("Тема: SpeakApp iOS v\(appVersion) (\(buildNumber)) feedback")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Divider().background(Color.white.opacity(0.2))
            
            ZStack {
                Color(hex: "#252528")
                TextEditor(text: $feedbackText)
                    .transparentScrolling()
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .frame(height: 120)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("App version: v\(appVersion) (\(buildNumber))")
                Text("iOS version: \(iosVersion)")
                Text("Device: \(deviceName)")
                Text("UID: \(uid)")
                Text("Source: settings")
                Text("Отправлено с iPhone")
                    .padding(.top, 16)
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
    }
    
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            print("Почта доступна: можно отправить письмо")
            showMailView = true
        } else {
            print("Почта недоступна: пользователь не настроил Mail")
            mailErrorAlert = true
        }
    }
}

// MARK: - Прозрачный фон для TextEditor
public extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}
