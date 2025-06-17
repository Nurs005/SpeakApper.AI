//
//  Network.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation
import Combine

protocol Networking {
    func executeURLRequest<T>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error> where T: Decodable
}

final class Network: Networking {
    func executeURLRequest<T>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error> where T: Decodable {
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                    
                    #if DEBUG
                    print("Data = \(String(describing: result.data.prettyPrintedJSONString))")
                    #endif
                    
                    throw URLError(.badServerResponse)
                }
                
                #if DEBUG
                print("URLRequest = \(urlRequest)")
                print("Result - \(result)")
                print("Data = \(String(describing: result.data.prettyPrintedJSONString))")
                #endif
                
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
