//
//  SearchView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 18.05.2025.
//

import SwiftUI

struct SearchView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(Coordinator.self) var coordinator
    @Environment(\.dismiss) private var dismiss
    @FocusState private var searchFieldIsFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            searchBar
            recordingsList
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(Color(.background).ignoresSafeArea())
        .onAppear { searchFieldIsFocused = true }
        .navigationBarBackButtonHidden(true)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 16) {
                Image(.mangnifyingglass)
                    .foregroundColor(.white.opacity(0.7))
                TextField(
                    "",
                    text: $viewModel.searchText,
                    prompt: Text("Поиск").foregroundColor(.white.opacity(0.7))
                )
                .font(.system(size: 17))
                .foregroundColor(.white)
                .focused($searchFieldIsFocused)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color("searchColor"))
            .cornerRadius(10)

            Button("Отменить") {
                viewModel.searchText = ""
                dismiss()
            }
            .font(.system(size: 17))
            .foregroundColor(.white)
        }
    }

    private var recordingsList: some View {
        List {
            ForEach(viewModel.filteredRecordingItemsViewModels, id: \.model.url) { itemVM in
                Button {
                    coordinator.push(.detail(recording: itemVM.model))
                } label: {
                    RecordingItemView(viewModel: itemVM)
                        .frame(height: 68)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .listRowInsets(EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.background))
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}
