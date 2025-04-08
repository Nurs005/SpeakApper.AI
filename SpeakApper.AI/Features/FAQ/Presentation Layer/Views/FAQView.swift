//
//  FAQView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct FAQView: View {
    @Environment(Coordinator.self) var coordinator
    @StateObject private var viewModel = FAQViewModel()
    @State private var expandedQuestion: Int? = nil
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .scaleEffect(1.3)
                Spacer()
            } else {
                faqTitleView
                faqListView
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#25242A").edgesIgnoringSafeArea(.all))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

// MARK: - UI Компоненты
fileprivate extension FAQView {
    
    var headerView: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            
            HStack {
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                Spacer()
            }
            
            HStack {
                Text("SpeakerApp")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color.white.opacity(0.5))
        }
    }
    
    var faqTitleView: some View {
        VStack(spacing: 16) {
            Text("FAQ")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(.white)
            
            Text("Find answers to frequently asked questions here")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
        }
    }
    
    var faqListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    faqItem(item: viewModel.items[index], index: index)
                }
            }
            .padding(.top, 8)
        }
    }
    
    func faqItem(item: FAQItem, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        expandedQuestion = (expandedQuestion == index ? nil : index)
                    }
                }) {
                    Image(systemName: expandedQuestion == index ? "xmark" : "plus")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            if expandedQuestion == index {
                Text(item.subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding([.horizontal, .bottom])
                    .transition(.opacity)
            }
        }
        .frame(height: expandedQuestion == index ? nil : 72)
        .background(Color(hex: "#2F2F37"))
        .cornerRadius(12)
    }
    
}
