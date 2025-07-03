//
//  DeleteAccountSurveyView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 12.03.2025.
//

import SwiftUI

struct DeleteAccountSurveyView: View {
    @Environment(Coordinator.self) var coordinator
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var selectedReason: String? = nil
    @State private var showFinalAlert = false
    
    let reasons = [
        "Payment issues",
        "Unstable or buggy",
        "Using another app",
        "Too expensive",
        "I don't use it",
        "App is hard to use",
        "Missing functionality",
        "Other"
    ]
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack {
                closeButton
                titleView
                reasonListView
                continueButton
            }
            
            if showFinalAlert {
                customFinalAlert()
            }
        }
    }
}

// MARK: - UI Components
private extension DeleteAccountSurveyView {
    var closeButton: some View {
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
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    var titleView: some View {
        Text("Select the main reason for deleting your account")
            .font(.system(size: 21, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 10)
    }
    
    var reasonListView: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(reasons, id: \.self) { reason in
                    HStack {
                        Text(reason)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { self.selectedReason == reason },
                            set: { if $0 { self.selectedReason = reason } else { self.selectedReason = nil } }
                        ))
                        .labelsHidden()
                        .toggleStyle(RadioButtonToggleStyle())
                    }
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedReason = reason
                        }
                    }
                }
            }
        }
    }
    
    var continueButton: some View {
        Button(action: {
            if selectedReason == "Other" {
                coordinator.presentSheet(.customFeedback)
            } else {
                withAnimation {
                    showFinalAlert = true
                }
            }
        }) {
            Text("Continue deletion")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedReason == nil ? Color(hex: "#FFD7D7").opacity(0.5) : Color(hex: "#FFD7D7"))
                .foregroundColor(.red)
                .cornerRadius(10)
        }
        .disabled(selectedReason == nil)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

private extension DeleteAccountSurveyView {
    func customFinalAlert() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Thank you for your feedback!")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Text("We can help resolve this issue. Please contact our support team and provide more details.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                supportButton
                deleteButton
            }
            .background(Color(hex: "#1B1A1A"))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
        .transition(.opacity)
    }
    
    var supportButton: some View {
        Button(action: {
            coordinator.presentSheet(.sendFeedback)
        }) {
            Text("Contact Support")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#6F7CFF"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
    
    var deleteButton: some View {
        Button(action: {
            deleteAccount()
        }) {
            Text("Delete account")
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

private extension DeleteAccountSurveyView {
    func deleteAccount() {
        print("Аккаунт удалён по причине: \(selectedReason ?? "")")
        Task {
            await authViewModel.deleteAccount()
            authViewModel.isLoggedIn = false
            coordinator.popToRoot()
        }
    }
}

struct RadioButtonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(configuration.isOn ? Color(hex: "#6F7CFF") : .gray, lineWidth: 2)
                .frame(width: 20, height: 20)
            
            if configuration.isOn {
                Circle()
                    .fill(Color(hex: "#6F7CFF"))
                    .frame(width: 12, height: 12)
            }
        }
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
            }
        }
    }
}
