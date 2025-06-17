//
//  FAQItem.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 23.03.2025.
//

import Foundation

struct FAQItem: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String

}

