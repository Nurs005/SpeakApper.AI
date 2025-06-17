//
//  QuickActionView.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import SwiftUI

struct QuickActionView: View {
    let actionType: QuickActionType
    let useShortTitle: Bool
    let isHorizontal: Bool
    let iconColor: Color
    let actionHandler: (QuickActionType) -> Void
    
    var body: some View {
        content
            .onTapGesture { actionHandler(actionType) }
    }
    
    @ViewBuilder
    private var content: some View {
        if isHorizontal {
            VStack(spacing: 8) {
                iconView
                titleView
            }
            .frame(width: 70)
        } else {
            HStack {
                iconView
                titleView
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 6)
            .background(Color("listColor"))
            .cornerRadius(10)
        }
     //   .frame(maxWidth: .infinity)

    }
    
    private var iconView: some View {
        Image(actionType.iconName)
            .renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(iconColor)
    }
    
    private var titleView: some View {
        Text(useShortTitle ? actionType.shortTitle : actionType.title)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
}
