//
//  SpeakApper_AIApp.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 25.01.2025.
//

import Firebase
import SwiftUI

@main
struct SpeakApper_AIApp: App {
    let dependencies = Dependencies()
    var coordinator: Coordinator
    @StateObject private var premiumStatus = PremiumStatusViewModel(subscriptionManager: .shared)

    init() {
        FirebaseApp.configure()
#if DEBUG
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
#endif        
        self.coordinator = Coordinator(typeRoot: .splash)
    }

    var body: some Scene {
        WindowGroup {
            CoordinatorView(
                coordinator: coordinator,
                dependencies: dependencies)
            .environmentObject(premiumStatus)
            .task {
                await dependencies.subscriptionManager.updatePurchasedProducts()
            }

            //                        RecordingDetailView(recording: Recording(
            //                            url: Bundle.main.url(forResource: "example-audio", withExtension: "m4a") ?? URL(fileURLWithPath: ""),
            //                            date: Date(),
            //                            sequence: 0,
            //                            transcription: "Это пример транскрипции"
            //                        ))

        }
    }
}
