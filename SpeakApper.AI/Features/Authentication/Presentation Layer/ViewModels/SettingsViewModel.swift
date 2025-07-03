//
//  SettingsViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 11.03.2025.
//

import Foundation
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var email: String = "Guest"
    @Published var isLoggedIn: Bool = false
    @Published var cacheSizeString = "(0 KB)"
    private let recordingUseCase: RecordingUseCaseProtocol
    
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel,
         recordingUseCase: RecordingUseCaseProtocol) {
        self.authViewModel  = authViewModel
        self.recordingUseCase = recordingUseCase
        self.email = authViewModel.email
        self.isLoggedIn = authViewModel.isLoggedIn
        updateCacheLabel()
    }
    
    convenience init(authViewModel: AuthViewModel) {
        let localDS  = RecordingLocalDataSource()
        let repo     = RecordingRepository(localDataSource: localDS)
        let useCase  = RecordingUseCase(repository: repo)
        
        self.init(authViewModel: authViewModel,
                  recordingUseCase: useCase)
    }
    
    func logout() {
        authViewModel.signOut()
        self.email = "Guest"
        self.isLoggedIn = false
    }
    
    func deleteAll() {
        recordingUseCase.deleteAllRecordings()
        updateCacheLabel()
    }
    
    private func updateCacheLabel() {
        let kb = Double(recordingUseCase.cacheSize()) / 1024
        cacheSizeString = "(\(Int(kb)) KB)"
    }
}
