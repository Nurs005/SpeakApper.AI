//
//  SubscriptionManager.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 17.06.2025.
//

import Foundation
import StoreKit
import SwiftUICore

final class SubscriptionManager: ObservableObject {
    // TODO: Pruducts identificator now is actualy hardcoded then we need get it by backend
    let productIds = ["01"]

    @Published
    private(set) var products: [Product] = []
    private var productsLoaded = false
    private(set) var purchasedProductIDs = Set<String>()
    private var updates: Task<Void, Never>? = nil

    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        self.updates?.cancel()
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }

    private func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    private func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
}
