//
//  SendFeedbackView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 11.03.2025.
//

import SwiftUI

struct SendFeedbackView: View {
    @Environment(Coordinator.self) var coordinator
    @State private var feedbackText: String = "Hi, SpeakApp Team!\n\nHere are my thoughts about my SpeakApp experience."

    // Данные из Info.plist
    private let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"

    private let iosVersion = UIDevice.current.systemVersion
    private let deviceModel = UIDevice.current.localizedModel
    private let deviceName = UIDevice.current.name
    private let uid = UUID().uuidString
    
    var body: some View {
        VStack(spacing: 12) {
            headerView
            contentBodyView
            footerView
        }
        .padding(.horizontal, 16)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - UI Компоненты
fileprivate extension SendFeedbackView {
    
    var headerView: some View {
        
        
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            HStack {
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Text("Отменить")
                        .foregroundColor(.blue)
                        .font(.system(size: 17))
                }
            }

                HStack(spacing: 8) {
                    Text("SpeakApp iOS v\(appVersion) (\(buildNumber)) feedback")
                        .font(.headline)
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Кому: feedback@speakapp.com")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text("Копия/Скрытая копия: e.akmaral024@icloud.com")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Text("Тема: SpeakApp iOS v\(appVersion) (\(buildNumber)) feedback")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Divider().background(Color.white.opacity(0.3))

            ZStack {
                Color.black
                TextEditor(text: $feedbackText)
                    .transparentScrolling()
                   .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.horizontal, 4)
            }
            .frame(height: 120)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 5) {
                Text("App version: v\(appVersion) (\(buildNumber))")
                Text("iOS version: \(iosVersion)")
                Text("Device: \(deviceName)")
                Text("UID: \(uid)")
                Text("Source: settings")
            }
            .font(.footnote)
            .foregroundColor(.white.opacity(0.7))
        }
    }

    var footerView: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Отправлено с iPhone")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 8)
                .padding(.bottom, 16)
        }
    }
    
    func sendFeedback() {
        print("Отзыв отправлен: \(feedbackText)")
        coordinator.dismissSheet()
    }
}

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
