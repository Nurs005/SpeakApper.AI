//  RecordingDetailViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.04.2025.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

@MainActor
final class RecordingDetailViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // MARK: — Существующие @Published
    @Published var transcriptionText: String = ""
    @Published var audioTitle: String = "Аудиозапись"
    @Published var audioDuration: String = ""
    @Published var isPlaying: Bool = false
    @Published var isTranscribing: Bool = false
    @Published var selectedLanguage: TranscriptionLanguage = .automatic
    
    // MARK: — Новые свойства для AI
    @Published var aiResult: String? = nil
    @Published var lastAIAction: String?           
    private var previousTranscriptionText = ""
    @Published var isAILoading = false
    @Published var aiError: String?

    // MARK: — Зависимости и внутреннее состояние
    private let transcriptionManager: TranscriptionManager
    private let recording: Recording
    private var audioPlayer: AVAudioPlayer?
    private var transcriptionCancellable: AnyCancellable?
    
    init(
        recording: Recording,
        transcriptionManager: TranscriptionManager = .shared
    ) {
        self.recording = recording
        self.transcriptionManager = transcriptionManager
        super.init()
        
        audioTitle = Self.generateTitle(from: "Транскрибируется...")
        transcriptionText = ""
        
        transcriptionCancellable = transcriptionManager.$transcriptions
            .map { $0[recording.url] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] maybeText in
                guard let self = self, let text = maybeText else { return }
                self.transcriptionText = text
                self.audioTitle = Self.generateTitle(from: text)
                self.isTranscribing = false
            }
        
        fetchDuration()
        if transcriptionManager.transcriptions[recording.url] == nil {
            fetchTranscription()
        }
        setupPlayer()
    }
    
    var audioURL: URL { recording.url }
    
    // MARK: — Транскрипция
    func fetchTranscription() {
        isTranscribing = true
        
        let callback: (String?) -> Void = { [weak self] text in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isTranscribing = false
                if let text = text, !text.isEmpty {
                    self.transcriptionText = text
                    self.audioTitle = Self.generateTitle(from: text)
                } else {
                    let placeholder = "Не удалось транскрибировать запись"
                    self.transcriptionText = placeholder
                    self.audioTitle = Self.generateTitle(from: placeholder)
                }
            }
        }
        
        let locales = selectedLanguage == .automatic
            ? ["ru-RU", "en-US"]
            : [selectedLanguage.rawValue]
        
        transcriptionManager.transcribeAudioWithFallback(
            url: recording.url,
            locales: locales,
            completion: callback
        )
    }
    
    func changeLanguage(to newLang: TranscriptionLanguage) {
        selectedLanguage = newLang
        fetchTranscription()
    }
    
    // MARK: — Длительность
    func fetchDuration() {
        let asset = AVURLAsset(url: recording.url)
        Task {
            if let durationValue = try? await asset.load(.duration) {
                let seconds = CMTimeGetSeconds(durationValue)
                let m = Int(seconds) / 60
                let s = Int(seconds) % 60
                self.audioDuration = String(format: "%02d:%02d", m, s)
            }
        }
    }
    
    // MARK: — Плеер
    private func setupPlayer() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = self
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.0
            audioPlayer?.prepareToPlay()
        } catch {
            print("Ошибка плеера: \(error)")
        }
    }
    
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
    
    func setPlaybackRate(_ newRate: Float) {
        guard let player = audioPlayer else { return }
        let wasPlaying = player.isPlaying
        let t = player.currentTime
        player.stop()
        player.enableRate = true
        player.rate = newRate
        player.currentTime = t
        if wasPlaying {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
        } else {
            player.prepareToPlay()
        }
    }
    
    // MARK: — Экспорт и шаринг
    func export(format: ExportFormat) {
        guard !transcriptionText.isEmpty else { return }
        ExportManager.export(text: transcriptionText, format: format)
    }
    
    func shareAudio() {
        let av = UIActivityViewController(
            activityItems: [recording.url],
            applicationActivities: nil
        )
        UIApplication.shared.windows.first?
            .rootViewController?
            .present(av, animated: true)
    }

    // MARK: — AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool) {
        stopPlayback()
    }
    
    // MARK: — Helpers
    static func generateTitle(from text: String) -> String {
        text.components(separatedBy: " ")
            .prefix(4)
            .joined(separator: " ")
    }
    
    
    // MARK: — AI интеграция
    private struct OpenAIResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }

    @MainActor
    func callAI(action: String) {
        guard !transcriptionText.isEmpty else {
            print("callAI: transcriptionText пустой — выходим")
            return
        }
        print("callAI: отправляем action = \(action)")
        print("    content prefix = \(transcriptionText.prefix(80))…")
        previousTranscriptionText = transcriptionText
        lastAIAction = action
        aiError = nil
        isAILoading = true
        Task {
            await performCallAI(action: action)
        }
    }

    @MainActor
    private func performCallAI(action: String) async {
        guard let url = URL(string: "https://mystical-height-454513-u4.uc.r.appspot.com/v1/gateway/ai") else {
            aiError = "Неверный URL"
            isAILoading = false
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Payload: Encodable { let action: String; let content: String }
        do {
            req.httpBody = try JSONEncoder().encode(Payload(action: action, content: transcriptionText))
        } catch {
            aiError = "Ошибка кодирования запроса: \(error)"
            isAILoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("callAI: status = \(status), bytes = \(data.count)")

            guard status == 200 else {
                throw URLError(.badServerResponse)
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("raw JSON:\n\(raw)")
            }
            
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content else {
                throw URLError(.cannotParseResponse)
            }
            print("callAI: получили контент длиной \(content.count)")

            transcriptionText = content
        } catch {
            aiError = error.localizedDescription
            print("callAI: ошибка — \(error)")
        }

        isAILoading = false
    }

      func undoAI() {
          guard lastAIAction != nil else { return }
          transcriptionText = previousTranscriptionText
          lastAIAction = nil
      }

      func redoAI() {
          guard let action = lastAIAction else { return }
          callAI(action: action)
      }

}
