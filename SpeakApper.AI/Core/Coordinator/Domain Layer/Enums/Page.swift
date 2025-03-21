//
//  Page.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation

enum Page: Hashable {
    case onboarding
    case main
    case recording
    case settings
    case account
    case login
    case authCode(email: String)
}
