//
//  QuickActionType.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

enum QuickActionType: CaseIterable {
    case importFiles
    case sendFeedback
    case requestFeature
    case faq
    
    var title: String {
        switch self {
            case .importFiles:
                return "Import files"
            case .sendFeedback:
                return "Send feedback"
            case .requestFeature:
                return "Request a feature"
            case .faq:
                return "FAQ"
        }
    }
    
    var shortTitle: String {
        switch self {
            case .importFiles:
                return "Import recording"
            case .sendFeedback:
                return "Feedback"
            case .requestFeature:
                return "Request feature"
            case .faq:
                return "FAQ"
        }
    }
    
    
    var iconName: String {
        switch self {
            case .importFiles:
                return "import"
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
        case .importFiles:
                return .apps
            case .sendFeedback, .requestFeature, .faq:
                return .support
        }
    }
    
    
    var sheet: Sheet {
        switch self {
            case .importFiles:
                return .importFiles
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
    return [.importFiles,  .requestFeature, .faq]
}

enum QuickActionCategory {
    case apps
    case support
}
