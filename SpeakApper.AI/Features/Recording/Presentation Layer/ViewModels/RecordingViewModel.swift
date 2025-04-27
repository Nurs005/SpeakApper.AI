//
//  RecordingViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import Foundation
import Combine

final class RecordingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var recordings: [Recording] = []
    @Published var searchText: String = ""
    @Published var transcriptions: [URL: String] = [:]
    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingURL: URL?
    
    var onSaveRecording: ((Recording) -> Void)?

    // MARK: - Dependencies
    let useCase: RecordingUseCaseProtocol
    let audioRecorder: AudioRecorder
    private let transcriptionManager = TranscriptionManager()
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(useCase: RecordingUseCaseProtocol = RecordingUseCase(
        repository: RecordingRepository(
            localDataSource: RecordingLocalDataSource()
        )
    )) {
        self.useCase = useCase
        self.audioRecorder = AudioRecorder(useCase: useCase)
        bindAudioEvents()
        fetchRecordings()
    }

    // MARK: - Binding Events
    private func bindAudioEvents() {
        audioRecorder.onFinishPlaying = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.currentlyPlayingURL = nil
            }
        }
    }
    
    // MARK: - Получение записей
    func fetchRecordings() {
        recordings = useCase.getRecordings().sorted { $0.date > $1.date }
        fetchTranscriptions()
    }
    
    // MARK: - Сохранение записи
    func handleSaveLastRecording() {
        guard let url = audioRecorder.lastRecordedURL,
              let duration = audioRecorder.lastRecordedDuration else { return }
        
        let newRecording = Recording(
            url: url,
            date: Date(),
            sequence: 0,
            transcription: nil,
            duration: duration
        )
        
        onSaveRecording?(newRecording)
        fetchRecordings()
    }

    // MARK: - Транскрипция
    private func fetchTranscriptions() {
        for recording in recordings {
            if let existing = transcriptions[recording.url] {
                print("Используем кэш для \(recording.url.lastPathComponent)")
                continue
            }
            
            if let existing = recording.transcription, !existing.isEmpty {
                transcriptions[recording.url] = existing
                continue
            }

            // Транскрипция
            transcriptionManager.transcribeAudio(url: recording.url) { [weak self] transcription in
                DispatchQueue.main.async {
                    if let text = transcription {
                        self?.transcriptions[recording.url] = text
                    }
                }
            }
        }
    }

    // MARK: - Воспроизведение
    func playRecording(_ recording: Recording) {
        if currentlyPlayingURL == recording.url && isPlaying {
            audioRecorder.stopPlayback()
            isPlaying = false
            currentlyPlayingURL = nil
        } else {
            audioRecorder.playRecording(url: recording.url) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        self?.currentlyPlayingURL = recording.url
                        self?.isPlaying = true
                    }
                }
            }
        }
    }

    // MARK: - Удаление записи
    func deleteRecording(_ recording: Recording) {
        audioRecorder.deleteRecording(url: recording.url)
        fetchRecordings()
    }

    // MARK: - Фильтрация
    func filteredRecordings() -> [Recording] {
        guard !searchText.isEmpty else { return recordings }

        return recordings.filter {
            $0.formattedDate.localizedCaseInsensitiveContains(searchText) ||
            $0.url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }
    }
    
   
}
