//
//  PremiumStatusViewModel.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 29.06.2025.
//

import Foundation
import Combine


final class PremiumStatusViewModel: ObservableObject {
    @Published var hasSubscription: Bool = false
    
    var maxRecordingDuration: TimeInterval {
        hasSubscription ? 1800 : 120
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(subscriptionManager: SubscriptionManager) {
        subscriptionManager.$hasUnlockedPro
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasSubscription, on: self)
            .store(in: &cancellables)
    }
}
