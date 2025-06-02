//
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
final class RecordingDetailViewModel: NSObject,
                                      ObservableObject,
                                      AVAudioPlayerDelegate {

    // MARK: – Dependencies
    private let recordingUseCase: RecordingUseCaseProtocol
    private let transcriptionManager: TranscriptionManager

    // MARK: – Model
    private(set) var recording: Recording
    private var audioPlayer: AVAudioPlayer?
    private var transcriptionCancellable: AnyCancellable?

    // MARK: – UI state
    @Published var transcriptionText: String = ""
    @Published var audioTitle: String = "Аудиозапись"
    @Published var audioDuration: String = ""
    @Published var isPlaying: Bool = false
    @Published var isTranscribing: Bool = false
    @Published var selectedLanguage: TranscriptionLanguage = .automatic

    // MARK: – AI
    @Published var aiError: String?
    @Published var isAILoading: Bool = false
    @Published var aiResult: String? = nil
    @Published var lastAIAction: String? = nil

   
    var audioURL: URL { recording.url }

    // MARK: – Undo/Redo support
    private var originalTranscription: String = ""
    private var previousTranscriptionText: String = ""
    private var previousLastAIAction: String? = nil

    var undoManager: UndoManager?

    // MARK: – Init

    init(
        recording: Recording,
        recordingUseCase: RecordingUseCaseProtocol,
        transcriptionManager: TranscriptionManager = .shared
    ) {
        self.recording           = recording
        self.recordingUseCase    = recordingUseCase
        self.transcriptionManager = transcriptionManager
        super.init()

        transcriptionText     = recording.transcription ?? ""
        originalTranscription = recording.transcription ?? ""
        audioTitle            = Self.generateTitle(from: transcriptionText)

        bindTranscriptions()
        fetchDuration()
        if transcriptionText.isEmpty {
            fetchTranscription()
        }
        setupPlayer()
    }

    // MARK: – Bind manager

    private func bindTranscriptions() {
        transcriptionCancellable = transcriptionManager.$transcriptions
            .receive(on: DispatchQueue.main)
            .sink { [weak self, url = recording.url] dict in
                guard
                    let self,
                    let text = dict[url]
                else { return }

                self.transcriptionText = text
                self.audioTitle        = Self.generateTitle(from: text)
                self.isTranscribing    = false
            }
    }

    // MARK: – Save / Revert

    func saveTranscription() {
        recordingUseCase.updateTranscription(
            for: recording.url,
            with: transcriptionText
        )
        originalTranscription = transcriptionText
    }

    func revertChanges() {
        transcriptionText = originalTranscription
    }

    // MARK: – Transcription

    func fetchTranscription() {
        isTranscribing = true
        let locales = selectedLanguage == .automatic
            ? ["ru-RU", "en-US"]
            : [selectedLanguage.rawValue]

        transcriptionManager.transcribeAudioWithFallback(
            url: recording.url,
            locales: locales
        ) { [weak self] text in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isTranscribing = false
                let result = text ?? "Не удалось транскрибировать запись"
                self.transcriptionText = result
                self.audioTitle        = Self.generateTitle(from: result)
            }
        }
    }

    func changeLanguage(to lang: TranscriptionLanguage) {
        selectedLanguage = lang
        fetchTranscription()
    }

    // MARK: – Duration

    private func fetchDuration() {
        Task {
            let seconds = try? await AVURLAsset(url: recording.url)
                .load(.duration)
                .seconds
            if let seconds {
                audioDuration = String(format: "%02d:%02d",
                                       Int(seconds) / 60,
                                       Int(seconds) % 60)
            }
        }
    }

    // MARK: – Player

    private func setupPlayer() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .default)
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Player error:", error)
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
        let wasPlaying  = player.isPlaying
        let position    = player.currentTime
        player.stop()
        player.enableRate = true
        player.rate       = newRate
        player.currentTime = position
        if wasPlaying {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
        }
    }

    // MARK: – Export / Share

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

    // MARK: – AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool) {
        stopPlayback()
    }

    // MARK: – Helpers

    static func generateTitle(from text: String) -> String {
        text.split(separator: " ").prefix(4).joined(separator: " ")
    }

    // MARK: – AI

    func callAI(action: String) {
        guard !transcriptionText.isEmpty else { return }
        
        previousTranscriptionText = transcriptionText
        previousLastAIAction      = lastAIAction

        lastAIAction = action
        aiError      = nil
        isAILoading  = true

        Task {
            await performCallAI(action: action)
        }
    }

    private func performCallAI(action: String) async {
        defer { isAILoading = false }

        guard let url = URL(string:
            "https://mystical-height-454513-u4.uc.r.appspot.com/v1/gateway/ai")
        else {
            aiError = "Неверный URL"
            return
        }

        struct Payload: Encodable {
            let action: String
            let content: String
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(
            Payload(action: action, content: transcriptionText)
        )

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            if let content = decoded.choices.first?.message.content {
                transcriptionText = content

                registerUndoForAI(
                    oldText: previousTranscriptionText,
                    oldAction: previousLastAIAction,
                    newText: content,
                    newAction: action
                )
            } else {
                throw URLError(.cannotParseResponse)
            }
        } catch {
            aiError = error.localizedDescription
        }
    }

    // MARK: – UNDO / REDO
    private func registerUndoForAI(
        oldText: String,
        oldAction: String?,
        newText: String,
        newAction: String
    ) {
        guard let undo = undoManager else { return }
        
        let redoText   = newText
        let redoAction = newAction

        undo.registerUndo(withTarget: self) { target in
            target.transcriptionText = oldText
            target.lastAIAction      = oldAction

            target.registerRedoForAI(
                afterText: redoText,
                afterAction: redoAction,
                previousText: oldText,
                previousAction: oldAction
            )
        }
        undo.setActionName("AI-действие")
    }

    private func registerRedoForAI(
        afterText: String,
        afterAction: String?,
        previousText: String,
        previousAction: String?
    ) {
        guard let undo = undoManager else { return }
        
        let undoText   = previousText
        let undoAction = previousAction

        undo.registerUndo(withTarget: self) { target in
            target.transcriptionText = afterText
            target.lastAIAction      = afterAction

            target.registerUndoForAI(
                oldText: undoText,
                oldAction: undoAction ?? nil,
                newText: afterText,
                newAction: afterAction ?? ""
            )
        }
        undo.setActionName("AI-действие")
    }

    func registerUndoForTextEdit(oldText: String) {
        guard let undo = undoManager else { return }
        
        let redoText = transcriptionText
        undo.registerUndo(withTarget: self) { target in
            target.transcriptionText = oldText
            target.registerRedoForTextEdit(afterText: redoText)
        }
        undo.setActionName("Редактирование транскрипции")
    }

    private func registerRedoForTextEdit(afterText: String) {
        guard let undo = undoManager else { return }

        let undoText = transcriptionText
        undo.registerUndo(withTarget: self) { target in
            target.transcriptionText = afterText
            
            target.registerUndoForTextEdit(oldText: undoText)
        }
        undo.setActionName("Редактирование транскрипции")
    }

    // MARK: – OpenAIResponse

    private struct OpenAIResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String }
            let message: Message
        }
        let choices: [Choice]
    }
}
