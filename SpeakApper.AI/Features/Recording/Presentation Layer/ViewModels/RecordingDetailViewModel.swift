//
//  RecordingDetailViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.04.2025.
//

import Foundation
import AVFoundation
import SwiftUI

final class RecordingDetailViewModel: ObservableObject {
    // MARK: - Published
    @Published var transcriptionText: String = ""
    @Published var audioTitle: String = "Аудиозапись"
    @Published var audioDuration: String = ""
    @Published var isPlaying: Bool = false
    @Published var isTranscribing: Bool = true

    // MARK: - Private
    private let recording: Recording
    private var audioPlayer: AVAudioPlayer?
    private let transcriptionManager = TranscriptionManager()

    // MARK: - Init
    init(recording: Recording) {
        self.recording = recording
        fetchTranscription()
        fetchDuration()
        setupPlayer()
    }

    // MARK: - Transcription
    func fetchTranscription() {
        if let existing = recording.transcription, !existing.isEmpty {
            self.transcriptionText = existing
            self.audioTitle = Self.generateTitle(from: existing)
            self.isTranscribing = false
            return
        }

        transcriptionManager.transcribeAudio(url: recording.url) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.transcriptionText = result ?? ""
                self.audioTitle = Self.generateTitle(from: result ?? "")
                self.isTranscribing = false
            }
        }
    }

    // MARK: - Audio Duration
    func fetchDuration() {
        let asset = AVURLAsset(url: recording.url)
        Task {
            do {
                let duration = try await asset.load(.duration)
                let seconds = CMTimeGetSeconds(duration)
                let min = Int(seconds) / 60
                let sec = Int(seconds) % 60

                DispatchQueue.main.async {
                    self.audioDuration = String(format: "%02d:%02d", min, sec)
                }
            } catch {
                print("Ошибка получения длительности: \(error)")
            }
        }
    }

    // MARK: - Player
    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }

    private func setupPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Ошибка инициализации плеера: \(error)")
        }
    }

    // MARK: - Title Generator
    static func generateTitle(from text: String) -> String {
        text.components(separatedBy: " ").prefix(4).joined(separator: " ")
    }
    
    // MARK: - Export
    func export(format: ExportFormat) {
        guard !transcriptionText.isEmpty else {
            print("Нет текста для экспорта")
            return
        }

        ExportManager.export(text: transcriptionText, format: format)
    }
    
    func setPlaybackRate(_ rate: Float) {
        audioPlayer?.rate = rate
        audioPlayer?.enableRate = true
    }

    func shareAudio() {
        let activityVC = UIActivityViewController(activityItems: [recording.url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
}
