//
//  PaywallSlideView.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 28.06.2025.
//

import SwiftUI


struct PaywallSlideView: View {
    let slide: PaywallSlide

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let features = slide.features {
                ForEach(features) { feature in
                    HStack {
                        if let icon = feature.icon {
                            Image(systemName: icon)
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        Text(feature.text)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        Spacer()
                    }
                }
            } else if let review = slide.review {
                VStack(alignment: .leading, spacing: 8) {
                    Text("**\(review.username)**")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))

                    HStack(spacing: 4) {
                        ForEach(0..<review.rating, id: \ .self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }

                    Text(review.reviewText)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .lineLimit(4)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

