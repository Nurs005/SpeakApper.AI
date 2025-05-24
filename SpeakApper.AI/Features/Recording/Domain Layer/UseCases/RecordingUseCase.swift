//
//  RecordingUseCase.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation
import AVFoundation

final class RecordingUseCase {
    private let repository: RecordingRepositoryInterface
    
    init(repository: RecordingRepositoryInterface) {
        self.repository = repository
    }
}

extension RecordingUseCase: RecordingUseCaseProtocol {
    func getRecordings() -> [Recording] {
        return repository.getRecordings()
    }
    
    func saveRecording(from url: URL, duration: TimeInterval) {
        repository.saveRecording(from: url, duration: duration)
    }
    
    func getAudioDuration(for recording: Recording) -> String {
        let asset = AVURLAsset(url: recording.url)
        let duration = asset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        let minutes = Int(durationInSeconds) / 60
        let seconds = Int(durationInSeconds) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public func deleteRecording(url: URL) {
        repository.deleteRecording(url: url)
    }
}
