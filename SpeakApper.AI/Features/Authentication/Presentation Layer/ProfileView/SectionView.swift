//
//  SectionView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 02.03.2025.
//

import Foundation
import SwiftUI

struct SectionView: View {
    let iconName: String
    let title: String
    var showChevron: Bool = true  
    
    var body: some View {
        HStack(spacing: 16) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }
}

