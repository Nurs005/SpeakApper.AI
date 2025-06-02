//
//  RecordingRepository.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation

protocol RecordingRepositoryInterface: AnyObject {
    func getRecordings() -> [Recording]
    func saveRecording(from url: URL, duration: TimeInterval)
    func deleteRecording(url: URL)
    func deleteAllRecordings()
    func cacheSize() -> Int
    
    func updateTranscription(for url: URL, with text: String)
}

final class RecordingRepository {
    private let localDataSource: RecordingLocalDataSourceInteface
    
    init(localDataSource: RecordingLocalDataSourceInteface) {
        self.localDataSource = localDataSource
    }
}

extension RecordingRepository: RecordingRepositoryInterface {
    func getRecordings() -> [Recording] {
        localDataSource.getRecordings()
    }
    
    func saveRecording(from url: URL, duration: TimeInterval) {
        localDataSource.saveRecording(from: url, duration: duration)
    }
    
    public func deleteRecording(url: URL) {
        localDataSource.deleteRecording(url: url)
    }
    
    func deleteAllRecordings() {
        try? localDataSource.deleteAllRecordings()
    }
    
    func cacheSize() -> Int {
        localDataSource.cacheSize()
    }
    
    func updateTranscription(for url: URL, with text: String) {
        localDataSource.updateTranscription(for: url, with: text)
    }
    
}
