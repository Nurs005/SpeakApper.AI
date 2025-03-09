//
//  QuickActionType.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

enum QuickActionType: CaseIterable {
    case `import`
    case youtube
    case newFeature
    case faq
    
    var title: String {
        switch self {
        case .import:
            return "Импорт записи"
        case .youtube:
            return "Youtube"
        case .newFeature:
            return "Запрос Функции"
        case .faq:
            return "FAQ"
        }
    }
    
    var iconName: String {
        switch self {
        case .import:
            return "import"
        case .youtube:
            return "youtube"
        case .newFeature:
            return "ai-idea"
        case .faq:
            return "faq"
        }
    }
    
    var sheet: Sheet {
        switch self {
        case .import:
            return .import
        case .youtube:
            return .youtube
        case .newFeature:
            return .newFeature
        case .faq:
            return .faq
        }
    }
}
