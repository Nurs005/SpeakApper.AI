//
//  MainViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation
import Combine

typealias MainDependencies = HasRecordingUseCase

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
        reloadRecordings()
    }

    func reloadRecordings() {
        let recordings = recordingUseCase.getRecordings()
        self.recordingItemsViewModels = recordings.map { RecordingItemViewModel(model: $0) }
    }

    func appendRecording(_ recording: Recording) {
        let vm = RecordingItemViewModel(model: recording)
        self.recordingItemsViewModels.insert(vm, at: 0)
    }
    
}
