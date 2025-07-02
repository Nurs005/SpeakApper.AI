//
//  AIFilterData.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import Foundation

struct AIFilterData {
    static let actionFilters: [FilterItem] = [
        FilterItem(title: "Translate", subtitle: "Translate text to another language"),
        FilterItem(title: "Add structure", subtitle: "Organize paragraphs and add punctuation"),
        FilterItem(title: "Summarize", subtitle: "Create a short summary"),
        FilterItem(title: "Detailed summary", subtitle: "Takeaways with details"),
        FilterItem(title: "Meeting minutes", subtitle: "Follow-up email summary"),
        FilterItem(title: "Bullet points", subtitle: "Convert text to a bulleted list"),
        FilterItem(title: "Rephrase", subtitle: "Rephrase the text")
    ]
    
    static let styleFilters: [FilterItem] = [
        FilterItem(title: "As an email", subtitle: "Format text like a business email"),
        FilterItem(title: "As a note", subtitle: "Convert text into a short note"),
        FilterItem(title: "As a blog post", subtitle: "Adapt text for a blog")
    ]
    
    static let toneFilters: [FilterItem] = [
        FilterItem(title: "Professional", subtitle: "Set a formal professional tone"),
        FilterItem(title: "Confident", subtitle: "Set a bold and confident tone"),
        FilterItem(title: "Casual", subtitle: "Make the tone relaxed and informal"),
        FilterItem(title: "Friendly", subtitle: "Add a warm friendly tone")
    ]
    
    static let funFilters: [FilterItem] = [
        FilterItem(title: "Create quiz", subtitle: "Generate a quiz from the transcript"),
        FilterItem(title: "Reply", subtitle: "Reply to the text"),
        FilterItem(title: "Song", subtitle: "Turn the text into a song"),
        FilterItem(title: "Angry", subtitle: "Add an angry tone to the text")
    ]
    
    static let customFilters: [FilterItem] = []
}
