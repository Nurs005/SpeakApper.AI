//
//  ImportType.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 16.03.2025.
//

import Foundation

enum ImportType: String, CaseIterable {
    case dictaphone, messengers, files
    
    var title: String {
        switch self {
            case .dictaphone: return "Dictaphone"
            case .messengers: return "Messengers"
            case .files: return "From Files"
        }
    }
    
    var steps: [ImportStep] {
        switch self {
            case .dictaphone:
                return [
                    ImportStep(imageName: "step1_dictaphone", title: "Step 1", description: "Open 'Dictaphone' and choose a recording"),
                    ImportStep(imageName: "step2_dictaphone", title: "Step 2", description: "Tap to share"),
                    ImportStep(imageName: "step3_dictaphone", title: "Step 3", description: "Select SpeakApper and share the audio")
                ]
            case .messengers:
                return [
                    ImportStep(imageName: "step1_messenger", title: "Step 1", description: "Open the messenger and select the voice message"),
                    ImportStep(imageName: "step2_messenger", title: "Step 2", description: "Select SpeakApper and share the audio")
                ]
            case .files:
                return [
                    ImportStep(imageName: "step1_files", title: "Step 1", description: "Open 'Files', choose the audio or voice file and tap 'Share'"),
                    ImportStep(imageName: "step2_files", title: "Step 2", description: "Select SpeakApper and share the audio")
                ]
        }
    }
}
