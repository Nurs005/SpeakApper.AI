//  AIActionView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 27.04.2025.
//


import SwiftUI

struct AIActionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecordingDetailViewModel
    @State private var selectedTab: AIFilter.FilterCategory = .action

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 1) Drag-indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 36, height: 4)
                    .padding(.vertical, 8)

                // 2) Tabs bar
                tabsView
                Divider().background(Color.white.opacity(0.15))

                // 3) Content: either result or list
                if let result = viewModel.aiResult {
                    resultView(result)
                } else {
                    filtersContentView()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Tabs
    private var tabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 32) {
                ForEach(AIFilter.FilterCategory.allCases, id: \.self) { cat in
                    tabButton(for: cat)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(hex: "#303030"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .frame(height: 56)
    }

    @ViewBuilder
    private func tabButton(for category: AIFilter.FilterCategory) -> some View {
        let selected = selectedTab == category
        Button {
            withAnimation { selectedTab = category }
        } label: {
            VStack(spacing: 6) {
                if let icon = category.iconName {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                } else {
                    Text(category.displayTitle)
                        .font(.system(size: 16, weight: selected ? .semibold : .regular))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .foregroundColor(selected ? .white : .white.opacity(0.6))
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay(
                Rectangle()
                    .fill(selected ? Color(hex: "#7B87FF") : .clear)
                    .frame(height: 3),
                alignment: .bottom
            )
        }
        .contentShape(Rectangle())
    }

    // MARK: - Filters list
    @ViewBuilder
    private func filtersContentView() -> some View {
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
        .background(Color(hex: "#1B1A1A"))
    }
    
    // MARK: - Custom Create Filter View
        private var customCreateFilterView: some View {
            VStack {
                Spacer()
                VStack(spacing: 32) {
                    Image(systemName: "wand.and.stars")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(Color(hex: "#7B87FF"))
                    Text("Создайте свой собственный AI-фильтр")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 32)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // action
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color(hex: "#7B87FF"))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
        }
    
    // MARK: - Filters List View
    private func filtersListView(_ filters: [FilterItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(filters) { filter in
                Button {
                    // on tap filter
                    viewModel.callAI(action: filter.apiActionName)
                } label: {
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
                        Image(systemName: "star")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 16)
                }
                Divider().background(Color.white.opacity(0.15))
            }
        }
    }

    // MARK: - Result view
    private func resultView(_ result: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        // back to list
                        viewModel.aiResult = nil
                        viewModel.aiError = nil
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                Text(result)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
            }
            .padding(16)
        }
        .background(Color(hex: "#1B1A1A"))
    }

    // MARK: - Helpers
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
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
