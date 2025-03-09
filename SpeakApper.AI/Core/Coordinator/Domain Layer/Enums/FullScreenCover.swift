//
//  FullScreenCover.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    // TODO: Remove paywall
    case paywall
}
