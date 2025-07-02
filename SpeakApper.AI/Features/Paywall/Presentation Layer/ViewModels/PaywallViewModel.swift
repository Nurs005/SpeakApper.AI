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

            // Заполняем мапу, группируя по типу
            for product in subscriptionManager.products {
                _ = makeSubscriptionOption(from: product)
            }

            // Теперь просто берем все уникальные опции
            self.SubscriptionOptions = Array(subscritpionMap.values)
            
        } catch {
            self.errorMessage = "Не удалось загрузить подписки"
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
                errorMessage = "Покупка не удалась"
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
    //               title: "Годовой план", subtitle: "всего 2 082 kzt в месяц",
    //               price: "24 990 kzt в год", isBestValue: true),
    //           SubscriptionOption(
    //               title: "3 дня бесплатно", subtitle: "затем 6 990 kzt в месяц",
    //               price: "", isBestValue: false),
    //       ]

    @Published var paywallSlides: [PaywallSlide] = [
        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "mic.fill", text: "Максимум 100 минут за запись"),
                PaywallFeature(
                    icon: "folder.fill", text: "Неограниченное число записей"),
                PaywallFeature(
                    icon: "wand.and.stars",
                    text: "AI-фильтры для редактирования текста"),
                PaywallFeature(icon: "globe", text: "Перевод на 20+ языков"),
                PaywallFeature(
                    icon: "square.and.arrow.down",
                    text: "Импорт и экспорт записей"),
            ], review: nil),

        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "mic.fill", text: "Максимум 100 минут за запись"),
                PaywallFeature(
                    icon: "folder.fill", text: "Неограниченное число записей"),
                PaywallFeature(
                    icon: "wand.and.stars",
                    text: "AI-фильтры для редактирования текста"),
                PaywallFeature(icon: "globe", text: "Перевод на 20+ языков"),
                PaywallFeature(
                    icon: "square.and.arrow.down",
                    text: "Импорт и экспорт записей"),
            ], review: nil),

        PaywallSlide(
            features: [
                PaywallFeature(
                    icon: "captions.bubble.fill",
                    text: "Автоматические субтитры"),
                PaywallFeature(
                    icon: "bubble.left.and.bubble.right.fill",
                    text: "Поддержка диалогов"),
                PaywallFeature(
                    icon: "textformat.abc", text: "Редактирование пунктуации"),
                PaywallFeature(
                    icon: "clock.arrow.circlepath", text: "Сохранение истории"),
            ], review: nil),

        PaywallSlide(
            features: nil,
            review:
                PaywallReview(
                    username: "marlmyn", rating: 5,
                    reviewText:
                        "SpeakApper – это отличное решение для тех, кто часто работает с аудио и хочет быстро получать качественные текстовые расшифровки. 🚀🔥"
                )
        ),
    ]
    
    var subscritpionMap: [ProductType : SubscriptionOption] = [:]
    @Published var SubscriptionOptions: [SubscriptionOption] = []
}
