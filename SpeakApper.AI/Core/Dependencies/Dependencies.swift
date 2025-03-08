//
//  Dependencies.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation

protocol HasRecordingRepository {
    var recordingRepository: RecordingRepositoryInterface { get }
}

final class Dependencies:
    HasRecordingRepository {
    private let network: Networking
    var recordingRepository: any RecordingRepositoryInterface
    
    init() {
        self.network = Network()
        recordingRepository = RecordingRepository(localDataSource: RecordingLocalDataSource())
    }
}

extension Dependencies: ObservableObject {}
