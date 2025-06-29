//
//  RecordingLocalDataSourceInteface.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation

protocol RecordingLocalDataSourceInteface: AnyObject {
    func getRecordings() -> [Recording]
    func saveRecording(from url: URL, duration: TimeInterval)
    func deleteRecording(url: URL)
    func deleteAllRecordings() throws
    func cacheSize() -> Int
    
    func updateTranscription(for url: URL, with text: String)
}
