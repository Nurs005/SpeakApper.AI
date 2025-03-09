//
//  RecordingView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVFoundation

struct RecordingView: View {
//    @Binding var isPresented: Bool
    @ObservedObject var viewModel: RecordingViewModel
//    @Binding var hasSavedRecording: Bool
    
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isPaused = false
    
    let maxRecordingDuration: TimeInterval = 120 // 2 минуты
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 24) {
                AudioWaveFormView(audioLevels: viewModel.audioRecorder.audioLevels)
                    .frame(height: 150)
                    .padding(.top, 60)
                
                Spacer()
                
                Text("\(formatTime(recordingTime)) / 2:00")
                    .font(.system(size: 53, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 48)
                
                AdView()
                    .padding(.horizontal)
                    .padding(.bottom, 72)
                
                HStack(spacing: 36) {
                    Button(action: {
                        stopRecording(delete: true)
//                        isPresented = false
                    }) {
                        VStack {
                            Image("xmarcBttn")
                                .resizable()
                                .frame(width: 42, height: 42)
                                .foregroundColor(.red)
                            Text("Отклонить")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        stopRecording(delete: false)
//                        hasSavedRecording = true
//                        isPresented = false
                    }) {
                        VStack {
                            Image("saveBttn")
                                .resizable()
                                .frame(width: 56, height: 56)
                                .foregroundColor(.green)
                            Text("Сохранить")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        togglePause()
                    }) {
                        VStack {
                            Image(isPaused ? "micBttn" : "pauseBttn")
                                .resizable()
                                .frame(width: 42, height: 42)
                                .foregroundColor(.yellow)
                            Text(isPaused ? "Возобновить" : "Пауза")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                startRecording()
            }
            .onDisappear {
                stopRecording(delete: false)
            }
        }
    }
    
    private func startRecording() {
        viewModel.audioRecorder.startRecording()
        startTimer()
    }
    
    private func stopRecording(delete: Bool) {
        viewModel.audioRecorder.stopRecording()
        timer?.invalidate()
        
        if delete, let lastRecording = viewModel.audioRecorder.recordings.last {
            viewModel.audioRecorder.deleteRecording(url: lastRecording.url)
        } else {
            viewModel.fetchRecordings()
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            viewModel.audioRecorder.audioRecorder?.pause()
            timer?.invalidate()
        } else {
            viewModel.audioRecorder.audioRecorder?.record()
            startTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if recordingTime < maxRecordingDuration {
                recordingTime += 1
            } else {
                stopRecording(delete: false)
//                isPresented = false
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}
