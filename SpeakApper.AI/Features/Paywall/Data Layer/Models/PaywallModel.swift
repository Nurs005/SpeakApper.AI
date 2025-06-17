//
//  PaywallModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import Foundation
import SwiftUI

struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String?
    let text: String
}

struct PaywallReview: Identifiable {
    let id = UUID()
    let username: String
    let rating: Int
    let reviewText: String
}

struct PaywallSlide: Identifiable {
    let id = UUID()
    let features: [PaywallFeature]?
    let review: PaywallReview?
}

struct SubscriptionOption: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let price: String
    let isBestValue: Bool
}

