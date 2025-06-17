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
            case .detail(let recording):
                buildDetailPage(for: recording)
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
            case .customFeedback:
                buildCustomFeedbackSheet()
            case .deleteSurveys:
                buildDeleteSurveysSheet()
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
        let vm = RecordingViewModel()
        return RecordingView(viewModel: vm)
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
    
//    func buildDetailPage(for recording: Recording) -> some View {
//        let vm = RecordingDetailViewModel(
//            recording: recording,
//            transcriptionManager: dependencies.transcriptionManager
//        )
//        return RecordingDetailView(viewModel: vm)
//    }
    func buildDetailPage(for recording: Recording) -> some View {
        let vm = RecordingDetailViewModel(
            recording:         recording,
            recordingUseCase:  dependencies.recordingUseCase,  
            transcriptionManager: dependencies.transcriptionManager
        )
        return RecordingDetailView(viewModel: vm)
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
        let viewModel = SettingsViewModel(authViewModel: AuthViewModel())
        return SendFeedbackView(viewModel: viewModel)
            .presentationDragIndicator(.hidden)
    }
    
    func buildCustomFeedbackSheet() -> some View {
        return CustomDeleteReasonView()
    }
    
    func buildDeleteSurveysSheet() -> some View {
        return DeleteAccountSurveyView()
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
