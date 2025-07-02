//
//  StartButtonView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 30.01.2025.
//

import SwiftUI

struct StartButtonView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        Button(action: {
            if viewModel.currentPage == 4 {
                viewModel.showPaywall = true
            } else {
                viewModel.nextPage()
            }
        }) {
            Text("Continue")
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
