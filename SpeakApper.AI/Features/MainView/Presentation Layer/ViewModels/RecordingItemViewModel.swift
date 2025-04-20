//
//  RecordingItemViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation
import Combine

final class RecordingItemViewModel: ObservableObject {
    let model: Recording
    @Published var title: String = "Новая запись"
    
    private let transcriptionManager = TranscriptionManager()
    private var cancellables = Set<AnyCancellable>()
    
    init(model: Recording) {
        self.model = model
        self.title = Self.generateTitle(from: model.transcription ?? "Транскрибируется...")
        
        if model.transcription == nil || model.transcription?.isEmpty == true {
            transcriptionManager.transcribeAudio(url: model.url) { [weak self] text in
                if let text, !text.isEmpty {
                    DispatchQueue.main.async {
                        self?.title = Self.generateTitle(from: text)
                    }
                }
            }
        }
    }
    
    private static func generateTitle(from text: String) -> String {
        text.components(separatedBy: " ").prefix(4).joined(separator: " ")
    }
    
    var date: String {
        model.formattedDate
    }
    
    var duration: String {
        let totalSeconds = Int(model.duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):" + String(format: "%02d", seconds)
    }
}

extension RecordingItemViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.url)
        hasher.combine(model.date)
        hasher.combine(model.duration)
    }
}

extension RecordingItemViewModel: Equatable {
    static func == (lhs: RecordingItemViewModel, rhs: RecordingItemViewModel) -> Bool {
        lhs.model.url == rhs.model.url &&
        lhs.model.date == rhs.model.date &&
        lhs.model.duration == rhs.model.duration
    }
}
