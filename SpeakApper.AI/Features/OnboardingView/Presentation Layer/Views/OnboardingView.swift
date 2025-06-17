//
//  ContentView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 25.01.2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showOnboarding = false
    @State private var isOnboardingFinished = false

    var body: some View {
        if isOnboardingFinished {
//            MainView()
        } else {
            VStack {
                if showOnboarding {
                    VStack {
                        TabView(selection: $viewModel.currentPage) { 
                            ForEach(0..<viewModel.steps.count, id: \.self) { index in
                                viewModel.steps[index]
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        PageControl(numberOfPages: viewModel.steps.count, currentPage: $viewModel.currentPage)
                            .padding(.top, -10)

                        if viewModel.currentPage != 2 {
                            StartButtonView(viewModel: viewModel)
                        }
                    }
                    .background(Color("BackgroundColor").ignoresSafeArea())
                } else {
                    WelcomeScreen()
                    Button(action: { showOnboarding = true }) {
                        Text("Продолжить")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ButtonColor"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
//            .fullScreenCover(isPresented: $viewModel.showPaywall) {
//                PaywallView(isOnboardingFinished: $isOnboardingFinished)
//            }
        }
    }
}
