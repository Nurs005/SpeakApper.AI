//
//  RecordingLocalDataSource.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation
import AVFoundation

final class RecordingLocalDataSource: RecordingLocalDataSourceInteface {
    private let fileManager = FileManager.default
    private lazy var docsDir: URL = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    func getRecordings() -> [Recording] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: docsDir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        let recordings = urls.compactMap { url -> Recording? in
            guard url.pathExtension.lowercased() == "m4a" else { return nil }
            let date = (try? url.resourceValues(forKeys: [.creationDateKey]))
                .flatMap(\.creationDate) ?? Date()
            let duration = getDuration(for: url)
            let transcription = UserDefaults.standard
                .string(forKey: "transcription_\(url.lastPathComponent)")
            return Recording(
                url: url,
                date: date,
                sequence: 0,
                transcription: transcription,
                duration: duration
            )
        }
        
        return recordings.sorted { $0.date > $1.date }
    }
    
    func saveRecording(from url: URL, duration: TimeInterval) {
        let destURL = docsDir.appendingPathComponent(url.lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.moveItem(at: url, to: destURL)
        } catch {
            print("Error saving recording: \(error.localizedDescription)")
        }
    }
    
    func deleteRecording(url: URL) {
        guard fileManager.fileExists(atPath: url.path) else {
            print("File not found: \(url.path)")
            return
        }
        do {
            try fileManager.removeItem(at: url)
            print("Deleted recording: \(url.lastPathComponent)")
        } catch {
            print("Error deleting recording at \(url.path): \(error.localizedDescription)")
        }
    }
    
    private func getDuration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
    
    func deleteAllRecordings() throws {
        let urls = try fileManager.contentsOfDirectory(at: docsDir,
                                                       includingPropertiesForKeys: nil,
                                                       options: [.skipsHiddenFiles])
        for url in urls where url.pathExtension.lowercased() == "m4a" {
            try fileManager.removeItem(at: url)
            UserDefaults.standard.removeObject(forKey: "transcription_\(url.lastPathComponent)")
        }
    }
    
    func cacheSize() -> Int {
        (try? fileManager.contentsOfDirectory(at: docsDir,
                                              includingPropertiesForKeys: [.fileSizeKey],
                                              options: [.skipsHiddenFiles]))?
            .reduce(0) { total, url in
                let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return total + size
            } ?? 0
    }
    
    // MARK: - Обновление транскрипции (UserDefaults)
    func updateTranscription(for url: URL, with text: String) {
        let key = "transcription_\(url.lastPathComponent)"
        UserDefaults.standard.set(text, forKey: key)
    }
}
