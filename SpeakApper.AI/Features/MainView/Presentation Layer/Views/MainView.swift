//
//  MainView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 02.02.2025.
//

import SwiftUI

struct MainView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(Coordinator.self) var coordinator
    
    var body: some View {
        contentBodyView
    }
}

fileprivate extension MainView {
    var contentBodyView: some View {
        VStack(spacing: 16) {
            headerView
            
            scrollableView
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 38) {
                if !viewModel.hasRecordings {
                    recordingTipView
                }
                
                startRecordingButtonView
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(
            Color(.background)
                .ignoresSafeArea()
        )
    }
    
    var headerView: some View {
        HStack(spacing: 0) {
            Text("SpeakApper")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                coordinator.push(.settings)
            } label: {
                Image(.settings)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    var scrollableView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                searchBarView
                
                if !viewModel.hasSubscription {
                    buyPremiumView
                }
                
                quickActionsView
                    .padding(.vertical, 16)
                
                recordingsView
            }
        }
    }
    
    var searchBarView: some View {
        HStack(spacing: 16) {
            Image(.mangnifyingglass)
            
            TextField("", text: $viewModel.searchText, prompt: Text("Поиск").foregroundColor(.white))
                .font(.system(size: 17))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color("searchColor"))
        .cornerRadius(10)
    }
    
    var buyPremiumView: some View {
        HStack(spacing: 4) {
            Image(.premiumLightning)
            
            Text("Попробуйте SpeakApper Premium бесплатно\nНажмите, чтобы попробовать сейчас!")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(colors: [Color(hex: "#6D4BCC"), Color(hex: "#5B51C9"), Color(hex: "#9856EA")],
                           startPoint: .leading,
                           endPoint: .trailing)
        )
        .cornerRadius(10)
    }
    
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
        LazyVStack(spacing: 24) {
            ForEach(viewModel.recordingItemsViewModels, id: \.self) { viewModel in
                NavigationLink(destination: RecordingDetailView(recording: viewModel.model)) {
                    RecordingItemView(viewModel: viewModel)
                }
                //RecordingItemView(viewModel: viewModel)
            }
        }
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
        Button {
            coordinator.push(.recording)
        } label: {
            Image(.startRecordingButton)
                .overlay(alignment: .bottom) {
                    startRecordingButtonTipView
                        .offset(x: 0, y: 24)
                }
        }
    }
    
    var startRecordingButtonTipView: some View {
        Image(.startRecordingButtonTip)
    }
}
