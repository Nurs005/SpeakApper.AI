//
//  YoutubeView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct YoutubeView: View {
    @Environment(Coordinator.self) var coordinator
    @State private var videoURL: String = ""
    @FocusState private var isInputActive: Bool

    var body: some View {
        contentBodyView
    }
}

// MARK: - UI Компоненты
fileprivate extension YoutubeView {
    
    var contentBodyView: some View {
        VStack(spacing: 16) {
            headerView
            descriptionView
            urlInputField
            Spacer()
            transcriptionButton
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
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                Spacer()
            }
            
            Text("YouTube в текст")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var descriptionView: some View {
        Text("Вы можете аудио из YouTube видео преобразовать в текст. Для этого вставьте ссылку ниже")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
            //.multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var urlInputField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#333333"))
            
            HStack {
                TextField("", text: $videoURL, prompt: Text("URL видео").foregroundColor(.gray))
                    .focused($isInputActive)
                    .padding(.leading, 16)
                    .foregroundColor(.white)

                if !videoURL.isEmpty {
                    Button(action: { videoURL = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.trailing, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .frame(height: 50)
    }

    var transcriptionButton: some View {
        Button(action: {
            // Действие 
        }) {
            Text("Транскрибировать")
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(videoURL.isEmpty ? Color(hex: "#6F7CFF").opacity(0.4) : Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(videoURL.isEmpty)
        .padding(.bottom, 24)
    }
}
