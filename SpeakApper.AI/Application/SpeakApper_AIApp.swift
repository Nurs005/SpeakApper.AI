//
//  SpeakApper_AIApp.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 25.01.2025.
//

import SwiftUI
import Firebase

@main
struct SpeakApper_AIApp: App {
    let dependencies = Dependencies()

    init() {
        FirebaseApp.configure() 
    }

    var body: some Scene {
        WindowGroup {
            
            MainView(dependencies: dependencies)
        }
    }
}
