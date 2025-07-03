//
//  OnboardingViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 29.01.2025.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var selectedCategory: String?
    @Published var selectedPurposes: Set<String> = []
    @Published var showPaywall = false
    
    lazy var steps: [AnyView] = [
        AnyView(OnboardingCardView(onboarding: onboardingData[0])), 
        AnyView(OnboardingCardView(onboarding: onboardingData[1])),
        AnyView(OnboardingSelectionPage(
            title: "Which category best describes you?",
            subtitle: "Your feedback will help make our app better!",
            options: [
                OptionModel(title: "Teacher or coach", icon: "Vector"),
                OptionModel(title: "IT professional", icon: "Vector8"),
                OptionModel(title: "Content creator", icon: "Vector1"),
                OptionModel(title: "Manager or entrepreneur", icon: "Vector5"),
                OptionModel(title: "Healthcare professional", icon: "Vector3"),
                OptionModel(title: "Student or learner", icon: "Vector6"),
                OptionModel(title: "Lawyer, finance, consultant", icon: "Vector4"),
                OptionModel(title: "Other", icon: "Vector7")
            ],
            currentPage: Binding(
                get: { self.currentPage },
                set: { self.currentPage = $0 }
            ),
            viewModel: self
                                       )),
        AnyView(OnboardingPurposePage(
            title: "What do you want to use our app for?",
            subtitle: "Your feedback will help make our app even better!",
            options: [
                OptionModel(title: "Translate foreign speech", icon: "Vector10"),
                OptionModel(title: "Transcribe meetings", icon: "Vector11"),
                OptionModel(title: "Transcribe lectures", icon: "Vector12"),
                OptionModel(title: "Write emails or messages", icon: "Vector13"),
                OptionModel(title: "I have a hearing impairment", icon: "Vector14"),
                OptionModel(title: "Keep personal voice notes", icon: "Vector15"),
                OptionModel(title: "Write social media posts or books", icon: "Vector16"),
                OptionModel(title: "Other", icon: "Vector17")
            ],
            currentPage: Binding(
                get: { self.currentPage },
                set: { self.currentPage = $0 }
            ),
            viewModel: self
        ))
    ]
    
    func nextPage() {
        if currentPage < steps.count - 1 {
            currentPage += 1
        } else {
            showPaywall = true
        }
    }
}
