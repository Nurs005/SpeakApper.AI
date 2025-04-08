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
    let coordinator = Coordinator()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: coordinator,
                            dependencies: dependencies)
            
//                        RecordingDetailView(recording: Recording(
//                            url: Bundle.main.url(forResource: "example-audio", withExtension: "m4a") ?? URL(fileURLWithPath: ""),
//                            date: Date(),
//                            sequence: 0,
//                            transcription: "Это пример транскрипции"
//                        ))
            
        }
    }
}
