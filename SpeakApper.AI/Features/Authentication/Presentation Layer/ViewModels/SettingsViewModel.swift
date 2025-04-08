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
    @Published var email: String = "Гость"
    @Published var isLoggedIn: Bool = false
    
    private let authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.email = authViewModel.email
        self.isLoggedIn = authViewModel.isLoggedIn
    }
    
    func logout() {
        authViewModel.signOut()
        self.email = "Гость"
        self.isLoggedIn = false
    }
}
