//
//  RecordingLocalDataSource.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation
import AVFoundation

final class RecordingLocalDataSource: RecordingLocalDataSourceInteface {
    
    func getRecordings() -> [Recording] {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
        let urls = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []

        return urls
            .filter { $0.pathExtension == "m4a" }
            .map { url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let date = (attributes?[.creationDate] as? Date) ?? Date()
                let duration = getDuration(for: url)

                return Recording(
                    url: url,
                    date: date,
                    sequence: 0,
                    transcription: nil,
                    duration: duration
                )
            }
        //return recordings.sorted { $0.date > $1.date }
    }

    func saveRecording(from url: URL, duration: TimeInterval) {
        let fileName = url.lastPathComponent
        print("Локально сохранено: \(fileName), длительность: \(duration) сек")
    }

    private func getDuration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
    
}

