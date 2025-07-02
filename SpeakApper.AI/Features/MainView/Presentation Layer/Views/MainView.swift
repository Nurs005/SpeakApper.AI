//
//  MainView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 02.02.2025.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(Coordinator.self) var coordinator
    @EnvironmentObject var premiumStatus: PremiumStatusViewModel
    
    @State private var isSearching = false
    @FocusState private var searchFieldIsFocused: Bool
    
    @State private var itemToDelete: RecordingItemViewModel?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            
            searchBarView
            
            if !premiumStatus.hasSubscription {
                BuyPremiumView()
            }
            
            
            
            quickActionsView
                .padding(.vertical, 16)
            
            recordingsView
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(Color(.background).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            VStack(spacing: 38) {
                if viewModel.recordingItemsViewModels.isEmpty {
                    recordingTipView
                        .padding(.horizontal, 16)
                }
                startRecordingButtonView
            }
            .padding(.bottom, 30)
        }
        
        .alert("Удалить запись?", isPresented: $showingDeleteAlert, presenting: itemToDelete) { item in
            Button("Удалить", role: .destructive) {
                viewModel.delete(item)
            }
            Button("Отмена", role: .cancel) {}
        }
    }
}

fileprivate extension MainView {
    var headerView: some View {
        HStack {
            Text("SpeakApper")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button { coordinator.push(.settings) } label: {
                Image(.settings).resizable().frame(width: 24, height: 24)
            }
        }
    }
    
    var searchBarView: some View {
        NavigationLink(destination: SearchView(viewModel: viewModel)) {
            HStack(spacing: 16) {
                Image(.mangnifyingglass)
                    .foregroundColor(.white.opacity(0.7))
                Text("Поиск")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color("searchColor"))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    
//    var buyPremiumView: some View {
//        Button(action: {
//            coordinator.presentFullCover(.paywall)
//        }){
//            HStack(spacing: 4) {
//                Image(.premiumLightning)
//                Text("Попробуйте SpeakApper Premium бесплатно\nНажмите, чтобы попробовать сейчас!")
//                    .font(.system(size: 15))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.leading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.vertical, 16)
//            .padding(.horizontal, 8)
//            .background(
//                LinearGradient(
//                    colors: [Color(hex: "#6D4BCC"), Color(hex: "#5B51C9"), Color(hex: "#9856EA")],
//                    startPoint: .leading, endPoint: .trailing
//                )
//            )
//            .cornerRadius(10)
//        }
//    }
    
    var quickActionsView: some View {
        HStack(alignment: .top, spacing: 27) {
            ForEach(mainQuickActions, id: \.self) { action in
                QuickActionView(
                    actionType: action,
                    useShortTitle: true,
                    isHorizontal: true,
                    iconColor: Color(hex: "#7B87FF")
                ) { selectedAction in
                    coordinator.presentSheet(selectedAction.sheet)
                }
            }
        }
    }
    
    
    var recordingsView: some View {
        List {
            ForEach(viewModel.recordingItemsViewModels, id: \.model.url) { itemVM in
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        itemToDelete = itemVM
                        showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .onAppear { viewModel.reloadRecordings() }
    }
    
    var recordingTipView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Начните запись")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Просто нажмите кнопку и сделайте свою первую голосовую запись на...")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mainTipBackground.opacity(0.18))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.mainTipStrokeBorder, lineWidth: 0.5)
                )
        )
    }
    
    var startRecordingButtonView: some View {
        Button { coordinator.push(.recording) } label: {
            Image(.startRecordingButton)
                .overlay(alignment: .bottom) {
                    Image(.startRecordingButtonTip)
                        .offset(x: 0, y: 24)
                }
        }
    }
    
    var startRecordingButtonTipView: some View {
        Image(.startRecordingButtonTip)
    }
    
}
