//
//  Sheet.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation

enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case importFiles
    case youtube
    case requestFeature
    case faq
    case sendFeedback
}
