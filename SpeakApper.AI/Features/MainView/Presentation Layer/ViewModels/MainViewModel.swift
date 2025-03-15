//
//  MainViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation
import Combine

typealias MainDependencies =
    HasRecordingUseCase

@Observable
final class MainViewModel {
    @ObservationIgnored private let recordingUseCase: RecordingUseCaseProtocol
    @ObservationIgnored private(set) var recordingItemsViewModels: [RecordingItemViewModel] = []
    
    var searchText: String = ""
    
    var hasRecordings: Bool {
        !recordingItemsViewModels.isEmpty
    }
    
    var hasSubscription: Bool {
        false
    }
    
    init(dependencies: MainDependencies) {
        self.recordingUseCase = dependencies.recordingUseCase
        
        recordingItemsViewModels = [RecordingItemViewModel(model: .init(url: URL(string: "https://www.youtube.com")!, date: Date(), sequence: 23, transcription: nil))]
    }
}
