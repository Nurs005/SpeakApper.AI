//
//  RecordingRepository.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import Foundation

protocol RecordingRepositoryInterface: AnyObject {
    func getRecordings()
}

final class RecordingRepository {
    private let localDataSource: RecordingLocalDataSourceInteface
    
    init(localDataSource: RecordingLocalDataSourceInteface) {
        self.localDataSource = localDataSource
    }
}

extension RecordingRepository: RecordingRepositoryInterface {
    func getRecordings() {
        localDataSource.getRecordings()
    }
}
