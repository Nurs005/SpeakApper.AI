//
//  RecordingItemViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation

final class RecordingItemViewModel {
    var title: String {
        "Добро пожаловать в SpeakerApp"
    }
    
    var date: String {
        "Только что"
    }
    
    var duration: String {
        "1:32"
    }
    
    init() {}
}

extension RecordingItemViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(date)
        hasher.combine(duration)
    }
}

extension RecordingItemViewModel: Equatable {
    static func == (lhs: RecordingItemViewModel, rhs: RecordingItemViewModel) -> Bool {
        lhs.title == rhs.title
        && lhs.date == rhs.date
        && lhs.duration == rhs.duration
    }
}
