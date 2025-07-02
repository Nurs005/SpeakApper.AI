//
//  PaywallModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import Foundation
import SwiftUI
import StoreKit

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

struct WrappedProduct: Equatable {
    let isTrialEnabled: Bool
    let underlyingProduct: Product
}

extension [WrappedProduct] {
    
    func getTrialProduct() -> Product? {
        for product in self {
            if  product.isTrialEnabled{
                return product.underlyingProduct
            }
        }
        return nil
    }
    
    func getNonTrialProduct() -> Product? {
        for product in self {
            if !product.isTrialEnabled {
                return product.underlyingProduct
            }
        }
        return nil
    }
    
}

struct SubscriptionOption: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let price: String
    let isBestValue: Bool
    var isTrialEnabled: Bool
    var underlyingProducts: [WrappedProduct]
}

