//
//  FAQRemoteDataSource.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 23.03.2025.
//

import Foundation
import Combine

final class FAQRemoteDataSource {
    private let network: Networking
    
    init(network: Networking = Network()) {
        self.network = network
    }
    func getFAQItems() -> AnyPublisher<[FAQItem], Error> {
        guard let url = URL(string: "https://www.speakapper.com/v1/gateway/faq") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return network.executeURLRequest(request)
            .map { (response: FAQResponse) in
                response.FAQ
            }
            .eraseToAnyPublisher()
    }
    
}
