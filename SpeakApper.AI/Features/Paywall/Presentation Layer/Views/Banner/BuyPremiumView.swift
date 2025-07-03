//
//  BuyPremiumView.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 29.06.2025.
//

import SwiftUI

struct BuyPremiumView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(.premiumLightning)
            Text("Try SpeakApper Premium for free\nTap to start now!")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(colors: [Color(hex: "#6D4BCC"), Color(hex: "#5B51C9"), Color(hex: "#9856EA")],
                           startPoint: .leading,
                           endPoint: .trailing)
        )
        .cornerRadius(10)
    }
}

//#Preview {
//    BuyPremiumView()
//}
