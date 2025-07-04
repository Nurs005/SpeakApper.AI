//
//  SettingsView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(Coordinator.self) var coordinator
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            VStack(spacing: 16) {
                backButton
                scrollableView
            }
            .navigationBarBackButtonHidden()
        }
    }
}

fileprivate extension SettingsView {
    var backButton: some View {
        Button(action: {
            if coordinator.path.count == 1 {
                coordinator.popToRoot()
            } else {
                coordinator.pop()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .padding(.top, 10)
    }
    
    var scrollableView: some View {
        VStack(spacing: 16) {
            title
            accountButton
            settingsForm
        }
    }
    
    var title: some View {
        Text("Settings")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
    
    var accountButton: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.email.isEmpty ? "Guest" : viewModel.email)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("Your account")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if viewModel.isLoggedIn {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            } else {
                Button(action: {
                    coordinator.push(.login)
                }) {
                    Text("Sign Up / Log In")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.white))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("ButtonColor"))
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            if viewModel.isLoggedIn {
                coordinator.push(.account)
            }
        }
    }
    
    var settingsForm: some View {
        Form {
            appSection
            supportSection
            dataManagementSection
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundColor"))
        .foregroundColor(.white)
    }
    
    var appSection: some View {
        Section(header: Text("App").textCase(nil).foregroundColor(.gray)) {
            VStack(spacing: 8) {
                ForEach(QuickActionType.allCases.filter { $0.category == .apps }, id: \.self) { action in
                    QuickActionView(
                        actionType: action,
                        useShortTitle: false,
                        isHorizontal: false,
                        iconColor: .white
                    ) { selectedAction in
                        coordinator.presentSheet(selectedAction.sheet)
                    }
                }
            }
        }
        .listRowBackground(Color("listColor"))
    }
    
    var supportSection: some View {
        Section(header: Text("Support & Feedback").textCase(nil).foregroundColor(.gray)) {
            VStack(spacing: 8) {
                ForEach(QuickActionType.allCases.filter { $0.category == .support }, id: \.self) { action in
                    QuickActionView(
                        actionType: action,
                        useShortTitle: false,
                        isHorizontal: false,
                        iconColor: .white
                    ) { selectedAction in
                        coordinator.presentSheet(selectedAction.sheet)
                    }
                }
            }
        }
        .listRowBackground(Color("listColor"))
    }
    
    var dataManagementSection: some View {
        Section(header: Text("Data Management").foregroundColor(.gray)) {
            Button(role: .destructive) { showAlert = true } label: {
                HStack(spacing: 16) {
                    Image(systemName: "trash")
                        .resizable().frame(width: 24, height: 24)
                    Text("Delete all recordings")
                    Spacer()
                    Text(viewModel.cacheSizeString)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.white)
            }
        }
        .alert("Delete all recordings?",
               isPresented: $showAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteAll()
            }
            Button("Cancel", role: .cancel) { }
        }
               .listRowBackground(Color("listColor"))
    }
    
}
