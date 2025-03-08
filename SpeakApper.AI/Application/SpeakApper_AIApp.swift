//
//  SpeakApper_AIApp.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 25.01.2025.
//

import SwiftUI

@main
struct SpeakApper_AIApp: App {
    let dependencies = Dependencies()
    
    var body: some Scene {
        WindowGroup {
//            OnboardingView()
            MainView(dependencies: dependencies)
        }
    }
}
