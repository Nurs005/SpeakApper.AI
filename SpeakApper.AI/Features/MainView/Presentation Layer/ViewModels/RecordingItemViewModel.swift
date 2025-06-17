//
//  RecordingItemViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation
import Combine

final class RecordingItemViewModel: ObservableObject, Hashable {
    let model: Recording
    private let transcriptionManager: TranscriptionManager
    private var cancellable: AnyCancellable?

    @Published var title: String = "Транскрибируется..."
    @Published var date: String
    @Published var duration: String

    init(
        model: Recording,
        transcriptionManager: TranscriptionManager = .shared
    ) {
        self.model = model
        self.transcriptionManager = transcriptionManager
        self.date = model.formattedDate
        let totalSec = Int(model.duration)
        let minutes = totalSec / 60
        let seconds = totalSec % 60
        self.duration = String(format: "%d:%02d", minutes, seconds)

        cancellable = transcriptionManager.$transcriptions
            .map { $0[model.url] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] maybeText in
                guard let text = maybeText, !text.isEmpty else { return }
                self?.title = Self.generateTitle(from: text)
            }

        if transcriptionManager.transcriptions[model.url] == nil {
            transcriptionManager.transcribeAudioWithFallback(url: model.url) { _ in }
        }
    }

    private static func generateTitle(from text: String) -> String {
        text.components(separatedBy: " ")
            .prefix(4)
            .joined(separator: " ")
    }

    // MARK: - Hashable & Equatable
    static func == (lhs: RecordingItemViewModel, rhs: RecordingItemViewModel) -> Bool {
        lhs.model.url == rhs.model.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.url)
    }
}
