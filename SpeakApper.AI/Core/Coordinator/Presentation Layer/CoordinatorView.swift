//
//  CoordinatorView.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import SwiftUI

struct CoordinatorView: View {
    @Bindable var coordinator: Coordinator
    let dependencies: Dependencies
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            buildPage(.main)
                .navigationDestination(for: Page.self) { page in
                    buildPage(page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    buildSheet(sheet)
                }
                .fullScreenCover(item: $coordinator.fullscreenCover) { cover in
                    buildFullCover(cover)
                }
        }
        .environment(coordinator)
    }
}

fileprivate extension CoordinatorView {
    @ViewBuilder
    func buildPage(_ page: Page) -> some View {
        switch page {
            case .onboarding:
                buildOnboardingPage()
            case .main:
                buildMainPage()
            case .recording:
                buildRecordingPage()
            case .settings:
                buildSettingsPage()
            case .account:
                buildAccountPage()
            case .login:
                buildLoginPage()
            case .authCode(let email):
                buildAuthCodePage(email: email)
        }
    }
    
    @ViewBuilder
    func buildSheet(_ sheet: Sheet) -> some View {
        switch sheet {
            case .importFiles:
                buildImportSheet()
            case .youtube:
                buildYoutubeSheet()
            case .requestFeature:
                buildNewFeatureSheet()
            case .faq:
                buildFAQSheet()
            case .sendFeedback:
                buildSendFeedbackSheet()
                
        }
    }
    
    @ViewBuilder
    func buildFullCover(_ cover: FullScreenCover) -> some View {
        switch cover {
            case .paywall:
                buildPaywallCover()
        }
    }
}

// MARK: Pages
fileprivate extension CoordinatorView {
    func buildOnboardingPage() -> some View {
        let viewModel = OnboardingViewModel()
        
        return OnboardingView(viewModel: viewModel)
    }
    
    func buildMainPage() -> some View {
        let viewModel = MainViewModel(dependencies: dependencies)
        
        return MainView(viewModel: viewModel)
    }
    
    func buildRecordingPage() -> some View {
        let viewModel = RecordingViewModel()
        
        return RecordingView(viewModel: viewModel)
    }
    
    func buildSettingsPage() -> some View {
        let viewModel = SettingsViewModel(authViewModel: AuthViewModel())
        
        return SettingsView(viewModel: viewModel)
    }
    
    func buildAccountPage() -> some View {
        return AccountSettingsView()
    }
    func buildLoginPage() -> some View {
        let authViewModel = AuthViewModel()
        return LoginView(authViewModel: authViewModel)
    }
    
    func buildAuthCodePage(email: String) -> some View {
        let authViewModel = AuthViewModel()
        return AuthCodeView(email: email, authViewModel: authViewModel)
    }
    
}

// MARK: Sheets
fileprivate extension CoordinatorView {
    func buildImportSheet() -> some View {
        return ImportRecordView()
    }
    
    func buildYoutubeSheet() -> some View {
        return YoutubeView()
    }
    
    func buildNewFeatureSheet() -> some View {
        return AIIdeaView()
    }
    
    func buildFAQSheet() -> some View {
        return FAQView()
    }
    
    func buildSendFeedbackSheet() -> some View {
        return SendFeedbackView()
            .presentationDragIndicator(.hidden)
    }
}

// MARK: FullCovers
fileprivate extension CoordinatorView {
    func buildPaywallCover() -> some View {
        let viewModel = PaywallViewModel()
        
        return PaywallView(paywallViewModel: viewModel,
                           isOnboardingFinished: .constant(true))
    }
}
