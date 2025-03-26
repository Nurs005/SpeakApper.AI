//
//  QuickActionType.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

enum QuickActionType: CaseIterable {
    case importFiles
    case youtube
    case sendFeedback
    case requestFeature
    case faq
    
    var title: String {
        switch self {
            case .importFiles:
                return "Импортировать файлы"
            case .youtube:
                return "Youtube to text"
            case .sendFeedback:
                return "Отправить отзыв"
            case .requestFeature:
                return "Запросить функцию"
            case .faq:
                return "Вопросы и ответы"
        }
    }
    
    var shortTitle: String {
        switch self {
            case .importFiles:
                return "Импорт записи"
            case .youtube:
                return "Youtube"
            case .sendFeedback:
                return "Отзыв"
            case .requestFeature:
                return "Запрос функция"
            case .faq:
                return "FAQ"
        }
    }
    
    
    var iconName: String {
        switch self {
            case .importFiles:
                return "import"
            case .youtube:
                return "youtube"
            case .sendFeedback:
                return "message-outlined"
            case .requestFeature:
                return "ai-idea"
            case .faq:
                return "faq"
        }
    }
    
    var category: QuickActionCategory {
        switch self {
            case .importFiles, .youtube:
                return .apps
            case .sendFeedback, .requestFeature, .faq:
                return .support
        }
    }
    
    
    var sheet: Sheet {
        switch self {
            case .importFiles:
                return .importFiles
            case .youtube:
                return .youtube
            case .sendFeedback:
                return .sendFeedback
            case .requestFeature:
                return .requestFeature
            case .faq:
                return .faq
        }
    }
}

var mainQuickActions: [QuickActionType] {
    return [.importFiles, .youtube, .requestFeature, .faq]
}

enum QuickActionCategory {
    case apps
    case support
}
