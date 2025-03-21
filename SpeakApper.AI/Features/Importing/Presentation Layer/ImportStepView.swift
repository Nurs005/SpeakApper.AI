//
//  ImportStepView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 16.03.2025.
//

import Foundation
import SwiftUI

struct ImportStepView: View {
    let step: ImportStep

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(step.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 297, height: 255)
                .cornerRadius(12)
                .padding(.top, 10)

            Text(step.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            Text(step.description)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(width: 361, height: 354)
        .padding()
        .background(Color(hex: "#2C2C2C").opacity(0.8))
        .cornerRadius(12)
    }
}
