//
//  QuickActionRowView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 11.03.2025.
//

import SwiftUI

struct QuickActionRowView: View {
    let actionType: QuickActionType
    let actionHandler: (QuickActionType) -> Void

    var body: some View {
        Button(action: {
            actionHandler(actionType)
        }) {
            HStack {
                Image(actionType.iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)

                Text(actionType.title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(Color("listColor"))
            .cornerRadius(10)
        }
    }
}
