//
//  QuickActionView.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import SwiftUI

struct QuickActionView: View {
    let actionType: QuickActionType
    
    var body: some View {
        VStack(spacing: 8) {
            iconView
            
            titleView
        }
        .frame(maxWidth: .infinity)
    }
    
    private var iconView: some View {
        Image(actionType.iconName)
            .resizable()
            .frame(width: 24, height: 24)
    }
    
    private var titleView: some View {
        Text(actionType.title)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2, reservesSpace: true)
    }
}
