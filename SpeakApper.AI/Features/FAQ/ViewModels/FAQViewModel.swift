//
//  FAQViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 23.03.2025.
//

import Foundation
import Combine

enum ViewState {
    case loading
    case content
    case empty
    case failure
}

final class FAQViewModel: ObservableObject {
    @Published var items: [FAQItem] = []
    @Published var state: ViewState = .loading
    
    private let dataSource: FAQRemoteDataSource
    private var cancellables = Set<AnyCancellable>()

    init(dataSource: FAQRemoteDataSource = FAQRemoteDataSource()) {
        self.dataSource = dataSource
        getFAQ()
    }

    func getFAQ() {
        state = .loading

        dataSource.getFAQItems()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.state = .failure
                }
            } receiveValue: { [weak self] faq in
                self?.items = faq
                self?.state = faq.isEmpty ? .empty : .content
            }
            .store(in: &cancellables)
    }
    
}
