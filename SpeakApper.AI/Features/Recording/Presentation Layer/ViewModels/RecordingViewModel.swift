//
//  RecordingViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import Foundation
import Combine

final class RecordingViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var searchText: String = ""
    @Published var transcriptions: [URL: String] = [:]
    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingURL: URL? = nil
    
    @Published var onSaveRecording: ((Recording) -> Void)?
    
    let useCase: RecordingUseCaseProtocol
    let audioRecorder: AudioRecorder
    private let transcriptionManager = TranscriptionManager()
    
    init(useCase: RecordingUseCaseProtocol = RecordingUseCase(
        repository: RecordingRepository(
            localDataSource: RecordingLocalDataSource()
        )
    )) {
        self.useCase = useCase
        self.audioRecorder = AudioRecorder(useCase: useCase)
        fetchRecordings()
        
        self.audioRecorder.onFinishPlaying = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.currentlyPlayingURL = nil
            }
        }
    }
    
    // MARK: - Получение записей
    func fetchRecordings() {
        recordings = useCase.getRecordings()
        fetchTranscriptions()
    }
    
    // MARK: - Сохранение записи (если не используется внутри AudioRecorder)
    func handleSaveLastRecording() {
        guard let url = audioRecorder.lastRecordedURL,
              let duration = audioRecorder.lastRecordedDuration else { return }
        
        let recording = Recording(
            url: url,
            date: Date(),
            sequence: 0,
            transcription: nil,
            duration: duration
        )
        
        onSaveRecording?(recording)
        
        fetchRecordings()
    }
    
    // MARK: - Транскрипция
    private func fetchTranscriptions() {
        for recording in recordings {
            transcriptionManager.transcribeAudio(url: recording.url) { [weak self] transcription in
                DispatchQueue.main.async {
                    if let transcription = transcription {
                        self?.transcriptions[recording.url] = transcription
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
    
    // MARK: - Удаление
    func deleteRecording(_ recording: Recording) {
        audioRecorder.deleteRecording(url: recording.url)
        fetchRecordings()
    }
    
    // MARK: - Фильтрация
    func filteredRecordings() -> [Recording] {
        if searchText.isEmpty {
            return recordings
        } else {
            return recordings.filter {
                $0.formattedDate.localizedCaseInsensitiveContains(searchText) ||
                $0.url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
