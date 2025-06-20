//
//  Dependencies.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

protocol HasRecordingUseCase {
    var recordingUseCase: RecordingUseCaseProtocol { get }
}

final class Dependencies:
    HasRecordingUseCase {
    private let network: Networking
    let transcriptionManager: TranscriptionManager = .shared
    var recordingUseCase: any RecordingUseCaseProtocol
    var subscriptionManager: SubscriptionManager!
    
    init() {
        self.network = Network()
        let recordingRepository = RecordingRepository(localDataSource: RecordingLocalDataSource())
        recordingUseCase = RecordingUseCase(repository: recordingRepository)
        subscriptionManager = SubscriptionManager()
    }
}

extension Dependencies: ObservableObject {}
