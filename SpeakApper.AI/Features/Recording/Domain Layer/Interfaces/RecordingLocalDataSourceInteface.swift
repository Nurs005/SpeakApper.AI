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
}
