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
            buildRootView()
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


extension CoordinatorView {
   
}

extension CoordinatorView {
    
    @ViewBuilder
    fileprivate func buildRootView() -> some View {
        switch coordinator.root {
        case .splash:
            buildSplashPage()
        case .onboarding:
            buildOnboardingPage()
        case .main:
            buildMainPage()
        }
    }
    
    @ViewBuilder
    fileprivate func buildPage(_ page: Page) -> some View {
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
    fileprivate func buildSheet(_ sheet: Sheet) -> some View {
        switch sheet {
        case .importFiles:
            buildImportSheet()
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
    fileprivate func buildFullCover(_ cover: FullScreenCover) -> some View {
        switch cover {
        case .paywall:
            buildPaywallCover()
        }
    }
}

// MARK: Pages
extension CoordinatorView {
    
    fileprivate func buildSplashPage() -> some View {
        return WelcomeScreen(onFinish: {
            coordinator.decideInitialFlow()
        })
    }
    
    fileprivate func buildOnboardingPage() -> some View {
        let viewModel = OnboardingViewModel()

        return OnboardingView(
            viewModel: viewModel,
            onFinish: {
                coordinator.presentFullCover(.paywall)
            })
    }

    fileprivate func buildMainPage() -> some View {
        let viewModel = MainViewModel(dependencies: dependencies)

        return MainView(viewModel: viewModel)
    }

    fileprivate func buildRecordingPage() -> some View {
        let vm = RecordingViewModel()
        return RecordingView(viewModel: vm)
    }

    fileprivate func buildSettingsPage() -> some View {
        let viewModel = SettingsViewModel(authViewModel: AuthViewModel())

        return SettingsView(viewModel: viewModel)
    }

    fileprivate func buildAccountPage() -> some View {
        return AccountSettingsView()
    }
    fileprivate func buildLoginPage() -> some View {
        let authViewModel = AuthViewModel()
        return LoginView(authViewModel: authViewModel)
    }

    fileprivate func buildAuthCodePage(email: String) -> some View {
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
    fileprivate func buildDetailPage(for recording: Recording) -> some View {
        let vm = RecordingDetailViewModel(
            recording: recording,
            recordingUseCase: dependencies.recordingUseCase,
            transcriptionManager: dependencies.transcriptionManager
        )
        return RecordingDetailView(viewModel: vm)
    }

}

// MARK: Sheets
extension CoordinatorView {
    fileprivate func buildImportSheet() -> some View {
        return ImportRecordView()
    }



    fileprivate func buildNewFeatureSheet() -> some View {
        return AIIdeaView()
    }

    fileprivate func buildFAQSheet() -> some View {
        return FAQView()
    }

    fileprivate func buildSendFeedbackSheet() -> some View {
        let viewModel = SettingsViewModel(authViewModel: AuthViewModel())
        return SendFeedbackView(viewModel: viewModel)
            .presentationDragIndicator(.hidden)
    }

    fileprivate func buildCustomFeedbackSheet() -> some View {
        return CustomDeleteReasonView()
    }

    fileprivate func buildDeleteSurveysSheet() -> some View {
        return DeleteAccountSurveyView()
    }
}

// MARK: FullCovers
extension CoordinatorView {
    fileprivate func buildPaywallCover() -> some View {
        let viewModel = PaywallViewModel()

        return PaywallView(
            paywallViewModel: viewModel,
            onFinish: {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                coordinator.dismissFullCover()
                coordinator.decideInitialFlow()
            })
        .onAppear() {
            Task{
                await viewModel.loadProducts()
            }
        }
    }
}
