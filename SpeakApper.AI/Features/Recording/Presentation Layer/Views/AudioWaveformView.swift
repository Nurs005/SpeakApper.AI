//
//  AudioWaveformView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 08.02.2025.
//

import SwiftUI

struct AudioWaveformView: View {
    var audioLevels: [CGFloat]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<audioLevels.count, id: \.self) { index in
                Capsule()
                    .fill(Color.purple.opacity(0.8))
                    .frame(width: 4, height: max(CGFloat(audioLevels[index]) * 100, 4))
                    .animation(.easeInOut(duration: 0.2), value: audioLevels[index])
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .frame(height: 160)
    }
}
