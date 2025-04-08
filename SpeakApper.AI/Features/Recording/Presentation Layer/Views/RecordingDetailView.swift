//
//  RecordingDetailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    let recording: Recording

    @ObservedObject var transcriptionManager = TranscriptionManager()
    @State private var transcriptionText = ""
    @State private var isTranscribing = true
    @State private var audioTitle = ""
    @State private var audioDuration = ""
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        contentBodyView
            .navigationBarHidden(true)
            .onAppear {
                startTranscription()
                fetchAudioDuration()
                setupAudioPlayer()
            }
            .onDisappear {
                stopAudio()
            }
    }
}

fileprivate extension RecordingDetailView {

    var contentBodyView: some View {
        ZStack(alignment: .bottom) {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 24) {
                headerView
                audioPlayerView

                if isTranscribing {
                    loadingView
                } else if transcriptionText.isEmpty {
                    errorView
                } else {
                    transcriptionScrollView
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal)

            bottomActionsView
        }
    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                // dismiss or navigation logic
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .medium))
            }

            Text(audioTitle.isEmpty ? "Аудиозапись" : audioTitle)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var audioPlayerView: some View {
        HStack(spacing: 12) {
            Button(action: togglePlayPause) {
                Circle()
                    .fill(Color(hex: "#7B87FF"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    )
            }

            HStack(spacing: 2) {
                ForEach(0..<30, id: \ .self) { _ in
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: CGFloat.random(in: 10...22))
                }
            }

            Spacer()

            Text(audioDuration)
                .foregroundColor(Color.white.opacity(0.5))
                .font(.subheadline)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#7B87FF")))
                .scaleEffect(1.4)
            Text("Транскрибирование аудиозаписи")
                .foregroundColor(.gray)
                .font(.system(size: 15))
            Spacer()
        }
    }

    var errorView: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Не удалось транскрибировать запись.")
                .foregroundColor(.gray)
                .font(.system(size: 15))
            Spacer()
        }
    }

    var transcriptionScrollView: some View {
        ScrollView {
            Text(transcriptionText)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    var bottomActionsView: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black.opacity(0.3))
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#7B87FF"))
                    .cornerRadius(10)
                }

                Spacer()

                HStack(spacing: 24) {
                    Button(action: {}) {
                        Image(systemName: "doc.on.doc")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

fileprivate extension RecordingDetailView {
    func startTranscription() {
        transcriptionManager.transcribeAudio(url: recording.url) { transcription in
            DispatchQueue.main.async {
                if let text = transcription, !text.isEmpty {
                    transcriptionText = text
                    audioTitle = text.components(separatedBy: " ").prefix(4).joined(separator: " ")
                } else {
                    transcriptionText = ""
                    audioTitle = "Аудиозапись"
                }
                isTranscribing = false
            }
        }
    }

    func fetchAudioDuration() {
        let asset = AVURLAsset(url: recording.url)
        Task {
            do {
                let duration = try await asset.load(.duration)
                let durationInSeconds = CMTimeGetSeconds(duration)

                let minutes = Int(durationInSeconds) / 60
                let seconds = Int(durationInSeconds) % 60

                DispatchQueue.main.async {
                    self.audioDuration = String(format: "%02d:%02d", minutes, seconds)
                }
            } catch {
                print("Ошибка загрузки длительности: \(error.localizedDescription)")
            }
        }
    }

    func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Ошибка при загрузке аудио: \(error.localizedDescription)")
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
}
