//
//  ImportRecordView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct ImportRecordView: View {
    @Environment(Coordinator.self) var coordinator
    @State private var selectedTab: ImportType = .dictaphone
    @Namespace private var animation
    @State private var isTabBarRounded: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            tabBarView
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(selectedTab.steps, id: \.self) { step in
                        ImportStepView(step: step)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // Заголовок
    private var headerView: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    coordinator.dismissSheet()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .padding(.leading, 8)
                
                Text("Импорт файлов")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
    }
    
    // Таб-бар
    private var tabBarView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "#303030"))
                .frame(height: 46)
                .frame(maxWidth: .infinity)
                .cornerRadius(12, corners: [.topLeft, .topRight])
            
            HStack(spacing: 0) {
                ForEach(ImportType.allCases, id: \.self) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = type
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(type.title)
                                .font(.system(size: 16, weight: selectedTab == type ? .bold : .regular))
                                .foregroundColor(selectedTab == type ? .white.opacity(0.9) : .gray)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                            
                            if selectedTab == type {
                                RoundedRectangle(cornerRadius: 2)
                                    .frame(width: 90, height: 2)
                                    .foregroundColor(Color("CircleColor"))
                                    .offset(y: 1)
                                    .matchedGeometryEffect(id: "underline", in: animation)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}
