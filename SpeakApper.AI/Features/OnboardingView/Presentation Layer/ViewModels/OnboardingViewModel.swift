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
            title: "Какая из категорий лучше всего описывает вас?",
            subtitle: "Ваш отзыв поможет сделать наше приложение лучше!",
            options: [
                OptionModel(title: "Преподаватель или Коуч", icon: "Vector"),
                OptionModel(title: "IT-специалист", icon: "Vector8"),
                OptionModel(title: "Автор контента", icon: "Vector1"),
                OptionModel(title: "Руководитель и предприниматель", icon: "Vector5"),
                OptionModel(title: "Медработник", icon: "Vector3"),
                OptionModel(title: "Студент или учащийся", icon: "Vector6"),
                OptionModel(title: "Юрист, финансист, консультант", icon: "Vector4"),
                OptionModel(title: "Другое", icon: "Vector7")
            ],
            currentPage: Binding(
                get: { self.currentPage },
                set: { self.currentPage = $0 }
            ),
            viewModel: self
                                       )),
        AnyView(OnboardingPurposePage(
            title: "Для чего вы хотите использовать наше приложение?",
            subtitle: "Ваш отзыв поможет сделать наше приложение еще лучше!",
            options: [
                OptionModel(title: "Переводить иностранную речь", icon: "Vector10"),
                OptionModel(title: "Транскрибировать встречи", icon: "Vector11"),
                OptionModel(title: "Транскрибировать лекции", icon: "Vector12"),
                OptionModel(title: "Составлять письма или сообщения", icon: "Vector13"),
                OptionModel(title: "У меня нарушение слуха", icon: "Vector14"),
                OptionModel(title: "Вести личные голосовые заметки", icon: "Vector15"),
                OptionModel(title: "Писать посты для соцсетей или книги", icon: "Vector16"),
                OptionModel(title: "Другое", icon: "Vector17")
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
