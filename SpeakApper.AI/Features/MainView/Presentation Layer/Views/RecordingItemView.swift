//
//  RecordingItemView.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 23.02.2025.
//

import SwiftUI

struct RecordingItemView: View {
    let viewModel: RecordingItemViewModel
    
    var body: some View {
        contentBodyView
    }
}

fileprivate extension RecordingItemView {
    var contentBodyView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                titleView
                
                HStack(spacing: 24) {
                    dateView
                    
                    durationTimeView
                }
            }
            
            Spacer()
            
            arrowView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.recordingItem)
        )
    }
    
    var titleView: some View {
        Text(viewModel.title)
            .font(.system(size: 17))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
    
    var dateView: some View {
        Text(viewModel.date)
            .font(.system(size: 12))
            .foregroundColor(.subtitle)
    }
    
    var durationTimeView: some View {
        HStack(spacing: 4) {
            Image(.time)
                .resizable()
                .frame(width: 16, height: 16)
            
            Text(viewModel.duration)
                .font(.system(size: 12))
                .foregroundColor(.subtitle)
        }
    }
    
    var arrowView: some View {
        Image(.arrowRight)
    }
}
