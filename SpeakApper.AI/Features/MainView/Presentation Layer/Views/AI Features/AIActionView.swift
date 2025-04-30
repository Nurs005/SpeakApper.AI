//
//  AIActionView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//

import SwiftUI

struct AIActionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: AIFilter.FilterCategory? = .action
    
    var body: some View {
        ZStack {
            Color(hex: "#1B1A1A")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // dragIndicator
                tabsView
                Divider()
                    .background(Color.white.opacity(0.15))
                contentScrollView
            }
        }
    }
}

// MARK: - Private Subviews
fileprivate extension AIActionView {
    
    //    var dragIndicator: some View {
    //        RoundedRectangle(cornerRadius: 2)
    //            .fill(Color.white)
    //            .frame(width: 36, height: 4)
    //            .padding(.top, 8)
    //            .padding(.bottom, 8)
    //    }
    
    var tabsView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(AIFilter.FilterCategory.allCases) { cat in
                        tabButton(for: cat)
                            .id(cat)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(Color(hex: "#303030"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .frame(height: 56)
    }

    
    @ViewBuilder
    private func tabButton(for category: AIFilter.FilterCategory) -> some View {
        let isSelected = selectedTab == category
        
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedTab = category
            }
        } label: {
            VStack(spacing: 6) {
                if let icon = category.iconName {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                } else {
                    Text(category.displayTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .overlay(
                Rectangle()
                    .fill(isSelected ? Color(hex: "#7B87FF") : .clear)
                    .frame(height: 3),
                alignment: .bottom
            )
        }
        .contentShape(Rectangle())
  
    }
    
    var  contentScrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                let filters = filtersForSelectedTab()
                if filters.isEmpty {
                    if selectedTab == .custom {
                        customCreateFilterView
                    } else {
                        Text("Здесь пока ничего нет")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 40)
                    }
                } else {
                    filtersListView(filters)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    var customCreateFilterView: some View {
        
            VStack(spacing: 36) {
                Spacer()
                
                Image(systemName: "wand.and.stars")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color(hex: "#7B87FF"))
                
                Text("Создайте свой собственный AI-фильтр")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: {
                    //
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: "#7B87FF"))
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
                //.padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                
            }
            .frame(maxWidth: .infinity)
        
    }


    
    func filtersListView(_ filters: [FilterItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(filters) { filter in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(filter.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        if let subtitle = filter.subtitle {
                            Text(subtitle)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Button(action: {
                        // Favorite action
                    }) {
                        Image(systemName: "star")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.vertical, 16)
                Divider()
                    .background(Color.white.opacity(0.15))
            }
        }
    }
    
    private func filtersForSelectedTab() -> [FilterItem] {
        switch selectedTab {
            case .action: return AIFilterData.actionFilters
            case .style:  return AIFilterData.styleFilters
            case .tone:   return AIFilterData.toneFilters
            case .fun:    return AIFilterData.funFilters
            case .custom: return AIFilterData.customFilters
            default:      return []
        }
    }
}

// MARK: - RoundedCorner Extension
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

