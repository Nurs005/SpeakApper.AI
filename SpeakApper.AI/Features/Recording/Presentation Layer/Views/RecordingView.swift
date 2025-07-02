//
//  RecordingView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVFoundation

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @Environment(Coordinator.self) var coordinator
    @EnvironmentObject var premiumStatus: PremiumStatusViewModel
    
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isPaused = false
    @State private var hasStopped = false
        
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 24) {
                AudioWaveformView(audioLevels: viewModel.audioRecorder.audioLevels.map { CGFloat($0) })
                    .frame(maxWidth: .infinity)
                  //  .padding(.horizontal, 16)
                
                Spacer()
                
                timerView
                
                if !premiumStatus.hasSubscription{
                    BuyPremiumView()
                        .padding(.bottom, 72)
                }
                
                controlsView
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true) 
        .onAppear { startRecording() }
        .onDisappear { stopRecording(delete: false) }
    }
}

// MARK: - Components
extension RecordingView {
    var timerView: some View {
        HStack(spacing: 6) {
            Text(formatTime(recordingTime))
                .foregroundColor(.white)
            Text(" / ")
                .foregroundColor(Color(hex: "#454358"))
            Text(formatTime(premiumStatus.maxRecordingDuration))
                .foregroundColor(Color(hex: "#454358"))
        }
        .font(.system(size: 53, weight: .bold))
    }
    
   
    
    var controlsView: some View {
        HStack(spacing: 32) {
            micControlButton(
                imageName: "xmark",
                text: "Отклонить",
                backgroundColor: Color(hex: "#3A3A47")
            ) {
                stopRecording(delete: true)
            }
            
            micControlButton(
                imageName: "stop",
                text: "Сохранить",
                backgroundColor: Color(hex: "#6F7CFF")
            ) {
                stopRecording(delete: false)
            }
            
            micControlButton(
                imageName: isPaused ? "mic.fill" : "pause",
                text: isPaused ? "Возобновить" : "Пауза",
                backgroundColor: Color(hex: "#2A2A34")
            ) {
                togglePause()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func micControlButton(
        imageName: String,
        text: String,
        backgroundColor: Color,
        iconColor: Color = .white,
        size: CGFloat = 56,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: size, height: size)
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.38, height: size * 0.38)
                        .foregroundColor(iconColor)
                }
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#7B7A94"))
            }
        }
    }
}

// MARK: - Logic
extension RecordingView {
    func startRecording() {
        viewModel.audioRecorder.startRecording()
        startTimer()
    }
    
    func stopRecording(delete: Bool) {
        guard !hasStopped else { return }
        hasStopped = true
        
        viewModel.audioRecorder.stopRecording(delete: delete)
        
        if delete,
           let url = viewModel.audioRecorder.lastRecordedURL {
            viewModel.audioRecorder.deleteRecording(url: url)
        }
        
        coordinator.pop()
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            viewModel.audioRecorder.pause()
            timer?.invalidate()
        } else {
            viewModel.audioRecorder.resume()
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if recordingTime < premiumStatus.maxRecordingDuration {
                recordingTime += 1
            } else {
                stopRecording(delete: false)
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}

