//
//  MainViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation
import Combine

typealias MainDependencies =
    HasRecordingRepository

final class MainViewModel: ObservableObject {
    private let dependencies: MainDependencies
    
    @Published var searchText: String = ""
    private(set) var recordingItemsViewModels: [RecordingItemViewModel] = []
    
    init(dependencies: MainDependencies) {
        self.dependencies = dependencies
        
        recordingItemsViewModels = [RecordingItemViewModel()]
    }
}
