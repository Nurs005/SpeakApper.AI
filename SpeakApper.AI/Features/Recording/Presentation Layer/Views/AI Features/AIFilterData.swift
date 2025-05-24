//
//  AIFilterData.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct AIFilterData {
    static let actionFilters: [FilterItem] = [
        FilterItem(title: "Перевести", subtitle: "Перевести текст на другой язык"),
        FilterItem(title: "Добавить структуру", subtitle: "Организовать абзацы и добавить пунктуацию"),
        FilterItem(title: "Резюмировать", subtitle: "Создать краткое резюме"),
        FilterItem(title: "Детально суммаризировать", subtitle: "Итоги с подробными деталями"),
        FilterItem(title: "Протокол встречи", subtitle: "Итоги для письма после встречи"),
        FilterItem(title: "Маркеры", subtitle: "Преобразовать текст в маркированный список"),
        FilterItem(title: "Переформулировать", subtitle: "Переформулировать текст")
    ]
    
    static let styleFilters: [FilterItem] = [
        FilterItem(title: "Как электронное письмо", subtitle: "Отформатировать текст как деловое письмо"),
        FilterItem(title: "Как заметку", subtitle: "Преобразовать текст в краткую заметку"),
        FilterItem(title: "Как пост в блоге", subtitle: "Адаптировать текст для блога")
    ]
    
    static let toneFilters: [FilterItem] = [
        FilterItem(title: "Профессиональный", subtitle: "Задать формальный, профессиональный тон"),
        FilterItem(title: "Уверенный", subtitle: "Задать смелый и уверенный тон"),
        FilterItem(title: "Простой", subtitle: "Сделать тон расслабленным и неформальным"),
        FilterItem(title: "Дружелюбный", subtitle: "Добавить тёплый, дружелюбный тон")
    ]
    
    static let funFilters: [FilterItem] = [
        FilterItem(title: "Создать тест", subtitle: "Создать тест из транскрипции"),
        FilterItem(title: "Reply", subtitle: "Reply to the text"),
        FilterItem(title: "Песня", subtitle: "Преобразовать текст в песню"),
        FilterItem(title: "Злой", subtitle: "Добавить сердитый тон в текст")
    ]
    
    static let customFilters: [FilterItem] = []
}
