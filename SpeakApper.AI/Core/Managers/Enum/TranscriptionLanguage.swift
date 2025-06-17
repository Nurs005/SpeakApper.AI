//
//  TranscriptionLanguage.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 30.04.2025.
//

import Foundation

enum TranscriptionLanguage: String, CaseIterable {
    case automatic = ""
    case english   = "en-US"
    case russian   = "ru-RU"
    case kazakh    = "kk-KZ"

    var displayName: String {
        switch self {
        case .automatic: return "Автоматически"
        case .english:   return "English"
        case .russian:   return "Русский"
        case .kazakh:    return "Қазақша"
        }
    }
}
