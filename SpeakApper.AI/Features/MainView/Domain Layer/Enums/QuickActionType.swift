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
                return "Import files"
            case .youtube:
                return "Youtube to text"
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
            case .youtube:
                return "Youtube"
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
