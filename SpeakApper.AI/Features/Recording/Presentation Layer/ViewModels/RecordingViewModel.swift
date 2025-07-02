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
    @Published var currentlyPlayingURL: URL?
    @Published var audioLevels: [Float] = []
    @Published var hasSubscription: Bool = false
    
    var onSaveRecording: ((Recording) -> Void)?
    
    // MARK: - Dependencies
    private let useCase: RecordingUseCaseProtocol
    let audioRecorder: AudioRecorder
    private let transcriptionManager: TranscriptionManager
    
    private var transcriptionCancellable: AnyCancellable?
    private var levelsCancellable: AnyCancellable?
    
    // MARK: - Init
    init(
        useCase: RecordingUseCaseProtocol = RecordingUseCase(
            repository: RecordingRepository(
                localDataSource: RecordingLocalDataSource()
            )
        ),
        transcriptionManager: TranscriptionManager = .shared
    ) {
        self.useCase = useCase
        self.transcriptionManager = transcriptionManager
        self.audioRecorder = AudioRecorder(useCase: useCase)
        
        bindAudioEvents()
        bindAudioLevels()
        bindTranscriptions()
        fetchRecordings()
    }
    
    // MARK: - Binding
    private func bindAudioEvents() {
        audioRecorder.onFinishRecording = { [weak self] in
            guard
                let self = self,
                let url = self.audioRecorder.lastRecordedURL,
                let duration = self.audioRecorder.lastRecordedDuration
            else { return }
            
            let newRec = Recording(
                url: url,
                date: Date(),
                sequence: 0,
                transcription: nil,
                duration: duration
            )
            self.fetchRecordings()
            DispatchQueue.main.async {
                self.onSaveRecording?(newRec)
            }
        }
        
        audioRecorder.onFinishPlaying = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.currentlyPlayingURL = nil
            }
        }
    }
    
    private func bindAudioLevels() {
        levelsCancellable = audioRecorder.$audioLevels
            .receive(on: DispatchQueue.main)
            .assign(to: \.audioLevels, on: self)
    }
    
    private func bindTranscriptions() {
        transcriptionCancellable = transcriptionManager.$transcriptions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cache in
                self?.transcriptions = cache
            }
    }
    
    // MARK: - Recordings
    func fetchRecordings() {
        recordings = useCase.getRecordings()
            .sorted { $0.date > $1.date }
        for recording in recordings {
            if transcriptionManager.transcriptions[recording.url] == nil {
                transcriptionManager.transcribeAudioWithFallback(url: recording.url) { _ in }
            }
        }
    }
    
    // MARK: - Playback
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
    
    // MARK: - Deletion
    func delete(at offsets: IndexSet) {
        offsets.forEach { idx in
            let rec = recordings[idx]
            useCase.deleteRecording(url: rec.url)
        }
        fetchRecordings()
    }
    
    // MARK: - Filtering
    func filteredRecordings() -> [Recording] {
        guard !searchText.isEmpty else { return recordings }
        return recordings.filter {
            $0.formattedDate.localizedCaseInsensitiveContains(searchText) ||
            $0.url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }
    }
}
