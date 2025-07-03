//
//  WelcomeScreen.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 30.01.2025.
//

import SwiftUI

struct WelcomeScreen: View {
    let onFinish: () -> Void
    var body: some View {
        VStack {
            Image("ellipse")
                .resizable()
                .frame(width: 140, height: 140)
                .padding()

            Text("SpeakApper")
                .font(.system(size: 41, weight: .bold))
                .foregroundColor(.white)
                .padding()

            Text(
                "Upload or record audio in any language for instant transcription."
            )
            .font(.system(size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}
