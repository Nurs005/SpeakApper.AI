//
//  AudioWaveformView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 08.02.2025.
//

import SwiftUI

struct AudioWaveFormView: View {
    let audioLevels: [CGFloat]

    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 2
    private let minHeight: CGFloat = 6
    private let maxHeight: CGFloat = 100
    private let barCornerRadius: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let totalSpacing = barSpacing * CGFloat(audioLevels.count - 1)
            let adjustedBarWidth = (availableWidth - totalSpacing) / CGFloat(audioLevels.count)

            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(audioLevels.indices, id: \.self) { index in
                    let level = audioLevels[index].clamped(to: 0.05...1.0)
                    let height = max(level * maxHeight, minHeight)

                    RoundedRectangle(cornerRadius: barCornerRadius)
                        .fill(Color(hex: "#454358"))
                        .frame(width: adjustedBarWidth, height: height)
                        .animation(.easeInOut(duration: 0.15), value: level)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: maxHeight)
        .padding(.horizontal, 12)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
