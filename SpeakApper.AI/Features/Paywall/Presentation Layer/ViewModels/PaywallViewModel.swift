//
//  PaywallViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 15.02.2025.
//

import Foundation
import SwiftUI

@MainActor
class PaywallViewModel: ObservableObject {    
    @Published var paywallSlides: [PaywallSlide] = [
        PaywallSlide(features: [
            PaywallFeature(icon: "mic.fill", text: "Максимум 100 минут за запись"),
            PaywallFeature(icon: "folder.fill", text: "Неограниченное число записей"),
            PaywallFeature(icon: "wand.and.stars", text: "AI-фильтры для редактирования текста"),
            PaywallFeature(icon: "globe", text: "Перевод на 20+ языков"),
            PaywallFeature(icon: "square.and.arrow.down", text: "Импорт и экспорт записей")
        ], review: nil),
        
        PaywallSlide(features: [
            PaywallFeature(icon: "mic.fill", text: "Максимум 100 минут за запись"),
            PaywallFeature(icon: "folder.fill", text: "Неограниченное число записей"),
            PaywallFeature(icon: "wand.and.stars", text: "AI-фильтры для редактирования текста"),
            PaywallFeature(icon: "globe", text: "Перевод на 20+ языков"),
            PaywallFeature(icon: "square.and.arrow.down", text: "Импорт и экспорт записей")
        ], review: nil),

        PaywallSlide(features: [
            PaywallFeature(icon: "captions.bubble.fill", text: "Автоматические субтитры"),
            PaywallFeature(icon: "bubble.left.and.bubble.right.fill", text: "Поддержка диалогов"),
            PaywallFeature(icon: "textformat.abc", text: "Редактирование пунктуации"),
            PaywallFeature(icon: "clock.arrow.circlepath", text: "Сохранение истории")
        ], review: nil),

        PaywallSlide(features: nil, review:
            PaywallReview(username: "marlmyn", rating: 5, reviewText: "SpeakApper – это отличное решение для тех, кто часто работает с аудио и хочет быстро получать качественные текстовые расшифровки. 🚀🔥")
        )
    ]
}
