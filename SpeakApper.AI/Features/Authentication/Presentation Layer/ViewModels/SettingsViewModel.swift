//
//  SettingsViewModel.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 11.03.2025.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var email: String

    private let authViewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.isLoggedIn = authViewModel.isLoggedIn
        self.email = authViewModel.email

        authViewModel.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.isLoggedIn = newValue
                self?.email = self?.authViewModel.email ?? "Гость"
            }
            .store(in: &cancellables)
    }

    func logout() {
        authViewModel.signOut()
    }
}
