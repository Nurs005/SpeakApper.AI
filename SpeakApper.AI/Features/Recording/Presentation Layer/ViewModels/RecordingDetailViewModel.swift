//
//  RecordingDetailViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.04.2025.
//

import Foundation
import AVFoundation
import SwiftUI

final class RecordingDetailViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // MARK: - Published Properties
    @Published var transcriptionText: String = ""
    @Published var audioTitle: String = "Аудиозапись"
    @Published var audioDuration: String = ""
    @Published var isPlaying: Bool = false
    @Published var isTranscribing: Bool = true

    // MARK: - Private Properties
    private let recording: Recording
    private var audioPlayer: AVAudioPlayer?
    private let transcriptionManager = TranscriptionManager()

    // MARK: - Init
    init(recording: Recording) {
        self.recording = recording
        super.init()
        fetchTranscription()
        fetchDuration()
        setupPlayer()
    }

    // MARK: - URL for Sharing
    var audioURL: URL {
        recording.url
    }

    // MARK: - Transcription
    func fetchTranscription() {
        if let existing = recording.transcription, !existing.isEmpty {
            transcriptionText = existing
            audioTitle = Self.generateTitle(from: existing)
            isTranscribing = false
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
                let minutes = Int(seconds) / 60
                let secs = Int(seconds) % 60
                DispatchQueue.main.async {
                    self.audioDuration = String(format: "%02d:%02d", minutes, secs)
                }
            } catch {
                print("Ошибка получения длительности: \(error)")
            }
        }
    }

    // MARK: - Player Setup
    private func setupPlayer() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.0
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
        } catch {
            print("Ошибка инициализации плеера: \(error)")
        }
    }

    // MARK: - Play / Pause
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            isPlaying = true
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }

    // MARK: - Playback Rate
    func setPlaybackRate(_ newRate: Float) {
        guard let player = audioPlayer else { return }
        let wasPlaying = player.isPlaying
        let currentTime = player.currentTime

        player.stop()
        player.enableRate = true
        player.rate = newRate
        player.currentTime = currentTime

        if wasPlaying {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
        } else {
            player.prepareToPlay()
        }
    }

    // MARK: - Title Generator
    static func generateTitle(from text: String) -> String {
        text
            .components(separatedBy: " ")
            .prefix(4)
            .joined(separator: " ")
    }

    // MARK: - Export Text
    func export(format: ExportFormat) {
        guard !transcriptionText.isEmpty else {
            print("Нет текста для экспорта")
            return
        }
        ExportManager.export(text: transcriptionText, format: format)
    }

    // MARK: - Share Audio
    func shareAudio() {
        let activityVC = UIActivityViewController(
            activityItems: [recording.url],
            applicationActivities: nil
        )
        UIApplication.shared.windows.first?
            .rootViewController?
            .present(activityVC, animated: true)
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayback()
    }
}
