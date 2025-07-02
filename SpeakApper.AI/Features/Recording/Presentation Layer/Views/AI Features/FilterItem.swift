//
//  AIFilter.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct FilterItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String?
}

extension FilterItem {
    var apiActionName: String {
        switch title {
        case "Translate": return "summarizePromt"
        case "Add structure": return "structurize"
        case "Summarize": return "summarizePromt"
        case "Detailed summary": return "summarizePromt"
        case "Meeting minutes": return "summarizePromt"
        case "Bullet points": return "summarizePromt"
        case "Rephrase": return "professional"
        case "As an email": return "business"
        case "As a note": return "note"
        case "As a blog post": return "blog"
        case "Professional": return "professional"
        case "Confident": return "professional"
        case "Casual": return "note"
        case "Friendly": return "friendly"
        case "Create quiz": return "nefor"
        case "Reply": return "professional"
        case "Song": return "song"
        case "Angry": return "angryBird"
        default: return "professional"
        }
    }
}
