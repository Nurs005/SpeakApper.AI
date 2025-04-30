//
//  AIFilter.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct AIFilter: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: FilterCategory
    
    enum FilterCategory: String, Codable, CaseIterable, Identifiable {
        case favorites = ""
        case action    = "Действие"
        case style     = "Стиль"
        case tone      = "Тон"
        case fun       = "Весело"
        case custom    = "Свой"
        
        var id: Self { self }
        
        var iconName: String? {
            switch self {
                case .favorites: return "star"
                default:         return nil
            }
        }
        
        var displayTitle: String { rawValue }
    }
}
