//
//  AIFilter.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct FilterItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String?
}

extension FilterItem {
    var apiActionName: String {
        switch title {
        case "Перевести": return "summarizePromt"
        case "Добавить структуру": return "structurize"
        case "Резюмировать": return "summarizePromt"
        case "Детально суммаризировать": return "summarizePromt"
        case "Протокол встречи": return "summarizePromt"
        case "Маркеры": return "summarizePromt"
        case "Переформулировать": return "professional"
        case "Как электронное письмо": return "business"
        case "Как заметку": return "note"
        case "Как пост в блоге": return "blog"
        case "Профессиональный": return "professional"
        case "Уверенный": return "professional"
        case "Простой": return "note"
        case "Дружелюбный": return "friendly"
        case "Создать тест": return "nefor"
        case "Reply": return "professional"
        case "Песня": return "song"
        case "Злой": return "angryBird"
        default: return "professional"
        }
    }
}
