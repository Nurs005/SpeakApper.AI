//
//  URLExtension.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

extension URL {
    static func getAPIURL(byPath path: String) -> URL? {
        // TODO: Add base api url
        URL(string: "BASEAPIURL" + path)
    }
}
