//
//  RecordingUseCaseProtocol.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation

protocol RecordingUseCaseProtocol: AnyObject {
    func getRecordings() -> [Recording]
    func saveRecording(from url: URL, duration: TimeInterval)
}
