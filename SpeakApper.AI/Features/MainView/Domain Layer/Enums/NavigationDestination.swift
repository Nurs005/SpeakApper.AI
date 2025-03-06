//
//  NavigationDestination.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

enum NavigationDestination: Hashable {
    case settings
    case `import`
    case youtube
    case newFeature
    case faq
    case login
    case authCode(email: String)
    case accountSettings
}

