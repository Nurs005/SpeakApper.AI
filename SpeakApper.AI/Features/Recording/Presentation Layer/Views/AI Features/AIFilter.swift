//
//  AIFilter.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct AIFilter: Identifiable, Equatable {
    let id = UUID()
    let category: FilterCategory

    enum FilterCategory: String, CaseIterable, Identifiable {
        case favorites = ""
        case action    = "Action"
        case style     = "Style"
        case tone      = "Tone"
        case fun       = "Fun"
        case custom    = "Custom"

        var id: Self { self }
        var iconName: String? { self == .favorites ? "star" : nil }
        var displayTitle: String { rawValue }
    }
}
