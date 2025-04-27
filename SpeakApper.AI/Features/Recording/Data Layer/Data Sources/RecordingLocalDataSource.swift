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
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let urls = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []

        return urls
            .filter { $0.pathExtension == "m4a" }
            .sorted(by: { lhs, rhs in
                let lhsDate = (try? fileManager.attributesOfItem(atPath: lhs.path)[.creationDate] as? Date) ?? Date()
                let rhsDate = (try? fileManager.attributesOfItem(atPath: rhs.path)[.creationDate] as? Date) ?? Date()
                return lhsDate > rhsDate
            })
            .map { url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let date = (attributes?[.creationDate] as? Date) ?? Date()
                let duration = getDuration(for: url)

                let transcription = UserDefaults.standard.string(forKey: "transcription_\(url.lastPathComponent)")

                return Recording(
                    url: url,
                    date: date,
                    sequence: 0,
                    transcription: transcription,
                    duration: duration
                )
            }
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

