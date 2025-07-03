//
//  PaywallView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 01.02.2025.
//

import SwiftUI

struct PaywallView: View {
    @ObservedObject var paywallViewModel: PaywallViewModel
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @State private var selectedOption: SubscriptionOption? = nil
    @State private var isTrialEnabled: Bool = false
    
    let onFinish: () -> Void

    var body: some View {
        VStack {
            // Close button
            HStack {
                Button(action: {
                    onFinish()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .bold))
                        .padding()
                }
                Spacer()
            }

            // Title
            Text("Choose a plan")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 36)

            // Отображение слайдов
            GeometryReader { geometry in
                if !paywallViewModel.paywallSlides.isEmpty {
                    let slide = paywallViewModel.paywallSlides[currentIndex]
                    PaywallSlideView(slide: slide)
                        .frame(maxWidth: .infinity, minHeight: geometry.size.height * 0.3, alignment: .top)
                }
            }
            .frame(maxHeight: 200)

            // Индикаторы страницы внизу слайдов
            HStack {
                ForEach(0..<paywallViewModel.paywallSlides.count, id: \ .self) { index in
                    Circle()
                        .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                        .foregroundColor(index == currentIndex ? Color("ButtonColor") : .gray.opacity(0.5))
                }
            }
            .padding(.top, 8)

            Spacer()
            SubscriptionOptionsView(
                selectedOption: $selectedOption,
                isTrialEnabled: $isTrialEnabled,
                options: paywallViewModel.SubscriptionOptions
            )
            Spacer()
            
            if let error = paywallViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                if  selectedOption != nil {
                    paywallViewModel.purchase(option: selectedOption!, isTrial: isTrialEnabled)
                  } else {
                      // For example simply close the paywall or do nothing
                      onFinish()
                  }
            }) {
                Text(
                    selectedOption == nil
                        ? "Continue"
                        : (paywallViewModel.isPurchasing ? "Purchasing..." : "Subscribe")
                )
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("ButtonColor"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            .disabled(selectedOption == nil || paywallViewModel.isPurchasing)
            .opacity(paywallViewModel.isPurchasing ? 0.5 : 1.0)

            // Terms
            HStack {
                Text("Terms of Use")
                Spacer()
                Text("Privacy Policy")
                Spacer()
                Text("Restore Purchases")
            }
            .foregroundColor(.gray)
            .font(.system(size: 14))
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor").ignoresSafeArea())
        .onReceive(timer) { _ in
            withAnimation {
                if !paywallViewModel.paywallSlides.isEmpty {
                    currentIndex = (currentIndex + 1) % paywallViewModel.paywallSlides.count
                }
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
