//
//  RecordingDetailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVFoundation

struct RecordingDetailView: View {
    @Environment(\.dismiss) var dismiss
    let recording: Recording
    @StateObject var viewModel = RecordingViewModel()
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
            Color(hex: "#252528").ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView
                audioPlayerView
                
                if isTranscribing {
                    loadingView
                } else if transcriptionText.isEmpty {
                    errorView
                } else {
                    transcriptionHeaderView
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
                dismiss()
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
            Button(action: {
                viewModel.playRecording(recording)
            }) {
                Circle()
                    .fill(Color(hex: "#6F7CFF"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: viewModel.currentlyPlayingURL == recording.url && viewModel.isPlaying ? "pause.fill" : "play.fill")
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Text(audioDuration)
                .foregroundColor(Color.white.opacity(0.5))
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color(hex: "#292A33"))
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
    
    
    var transcriptionHeaderView: some View {
        HStack(spacing: 8) {
            Text("Транскрипция - English (авто)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            
            Spacer()
            
            HStack(spacing: 16) {
                Image("lets-icons_back")
                Image("lets-icons_right")
            }
            .font(.system(size: 24))
        }
        .padding(.bottom, 4)
    }
    
    var transcriptionScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(transcriptionText)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                bottomShadowView
            }
            //.padding(.horizontal)
        }
    }
    
    var bottomShadowView: some View {
        HStack(spacing: 20) {
            Image(systemName: "hand.thumbsup")
            Image(systemName: "hand.thumbsdown")
            Image(systemName: "arrow.clockwise")
        }
        .font(.system(size: 14))
        .foregroundColor(.gray)
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
                    .padding(.vertical, 8)
                    .background(Color(hex: "#6F7CFF"))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button(action: {}) {
                        Image("cil_copy")
                            .font(.system(size: 24))
                        //.foregroundColor(.gray)
                    }
                    
                    Button(action: {}) {
                        Image("ph_export")
                            .font(.system(size: 24))
                        //.foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#1B1A1A"))
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
