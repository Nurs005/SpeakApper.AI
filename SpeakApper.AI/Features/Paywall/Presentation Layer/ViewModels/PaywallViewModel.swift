//
//  PaywallViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 15.02.2025.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var availableProducts: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String?

    private let subscriptionManager: SubscriptionManager

    init(subscriptionManager: SubscriptionManager = .shared) {
        self.subscriptionManager = subscriptionManager
    }

    func loadProducts() async {
        do {
            try await subscriptionManager.loadProducts()
            self.availableProducts = subscriptionManager.products

            // Очищаем мапу и опции
            self.subscritpionMap = [:]
            self.SubscriptionOptions = []

            // Fill the map, grouping by type
            for product in subscriptionManager.products {
                _ = makeSubscriptionOption(from: product)
            }

            // Grab all unique options
            self.SubscriptionOptions = Array(subscritpionMap.values)
            
        } catch {
            self.errorMessage = "Failed to load subscriptions"
        }
    }


    func purchase(option: SubscriptionOption, isTrial: Bool ) {
        Task {
            do {
                isPurchasing = true
                print("trial: \(isTrial)")
                guard let product = isTrial ? option.underlyingProducts.getTrialProduct() : option.underlyingProducts.getNonTrialProduct() else {
                    throw NilProductsInCase.fail
                }
                try await subscriptionManager.purchase(product)
            } catch {
                errorMessage = "Purchase failed"
            }
            isPurchasing = false
        }
    }

    private func makeSubscriptionOption(from product: Product) -> SubscriptionOption? {
        guard let type = ProductType(id: product.id) else { return nil }

        let isTrialEnabled = product.subscription?.introductoryOffer?.paymentMode == .freeTrial
        let currencyCode = product.priceFormatStyle.currencyCode
        let wrappedProduct = WrappedProduct(isTrialEnabled: isTrialEnabled, underlyingProduct: product)

        if var existing = subscritpionMap[type] {
            // CASE 2 — уже был этот тип
            existing.underlyingProducts.append(wrappedProduct)
            if existing.underlyingProducts.getTrialProduct() != nil {
                existing.isTrialEnabled = true
            }

            subscritpionMap[type] = existing
            return existing
        } else {
            // CASE 1 — первый продукт такого типа
            let option = SubscriptionOption(
                title: type.title,
                subtitle: type.formattedSubtitle(totalPrice: product.price, currencyCode: currencyCode),
                price: type.formattedTotalPrice(totalPrice: product.price, currencyCode: currencyCode),
                isBestValue: type.isBestValue,
                isTrialEnabled: isTrialEnabled,
                underlyingProducts: [wrappedProduct]
            )
            subscritpionMap[type] = option
            return option
        }
    }


    //           SubscriptionOption(
    //               title: "Annual plan", subtitle: "just 2 082 kzt per month",
    //               price: "24 990 kzt per year", isBestValue: true),
    //           SubscriptionOption(
    //               title: "3 days free", subtitle: "then 6 990 kzt per month",
    //               price: "", isBestValue: false),
    //       ]

    @Published var paywallSlides: [PaywallSlide] = [
        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "mic.fill", text: "Up to 100 minutes per recording"),
                PaywallFeature(
                    icon: "folder.fill", text: "Unlimited recordings"),
                PaywallFeature(
                    icon: "wand.and.stars",
                    text: "AI filters for text editing"),
                PaywallFeature(icon: "globe", text: "Translation to 20+ languages"),
                PaywallFeature(
                    icon: "square.and.arrow.down",
                    text: "Import and export recordings"),
            ], review: nil),

        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "mic.fill", text: "Up to 100 minutes per recording"),
                PaywallFeature(
                    icon: "folder.fill", text: "Unlimited recordings"),
                PaywallFeature(
                    icon: "wand.and.stars",
                    text: "AI filters for text editing"),
                PaywallFeature(icon: "globe", text: "Translation to 20+ languages"),
                PaywallFeature(
                    icon: "square.and.arrow.down",
                    text: "Import and export recordings"),
            ], review: nil),

        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "captions.bubble.fill",
                    text: "Automatic captions"),
                PaywallFeature(
                    icon: "bubble.left.and.bubble.right.fill",
                    text: "Conversation support"),
                PaywallFeature(
                    icon: "textformat.abc", text: "Punctuation editing"),
                PaywallFeature(
                    icon: "clock.arrow.circlepath", text: "History saving"),
            ], review: nil),

        PaywallSlide(
            features: nil,
            review:
                PaywallReview(
                    username: "marlmyn", rating: 5,
                    reviewText:
                        "SpeakApper is an excellent solution for those who often work with audio and want quick, high-quality transcriptions. 🚀🔥"
                )
        ),
    ]
    
    var subscritpionMap: [ProductType : SubscriptionOption] = [:]
    @Published var SubscriptionOptions: [SubscriptionOption] = []
}
