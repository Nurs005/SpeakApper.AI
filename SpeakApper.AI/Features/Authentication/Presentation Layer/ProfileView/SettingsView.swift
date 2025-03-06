//
//  SettingsView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var navigateToLogin = false
    @State private var showAccountSettings = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        contentBodyView
    }
}

fileprivate extension SettingsView {
    var contentBodyView: some View {
        ZStack {
            Color(.background).ignoresSafeArea()
            VStack(spacing: 16) {
                backButton
                scrollableView
            }
        }
    }
    
    var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Назад")
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
        Text("Настройки")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
    
    @ViewBuilder
    var accountButtonDestination: some View {
        if authViewModel.isLoggedIn {
            AccountSettingsView()
        } else {
            LoginView()
        }
    }

    var accountButton: some View {
        NavigationLink(destination: NavigationDestination.login) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.email.isEmpty ? "Гость" : authViewModel.email)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Ваш аккаунт")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 16)
    }


    
    var settingsForm: some View {
        Form {
            appSection
            supportSection
            dataManagementSection
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundColor"))
        .foregroundStyle(.white)
        .navigationBarBackButtonHidden(true)
    }
    
    var appSection: some View {
        Section(header: Text("Приложение").textCase(nil).foregroundColor(.gray)) {
            NavigationLink(value: NavigationDestination.import) {
                SectionView(iconName: "uil_import", title: "Импортировать файлы")
            }
            NavigationLink(value: NavigationDestination.youtube) {
                SectionView(iconName: "iconoir_youtube", title: "Youtube to text")
            }
            NavigationLink(value: NavigationDestination.newFeature) {
                SectionView(iconName: "share-line", title: "Поделиться с другом")
            }
        }
        .listRowBackground(Color("listColor"))
    }
    
    var supportSection: some View {
        Section(header: Text("Поддержка и обратная связь").textCase(nil).foregroundColor(.gray)) {
            NavigationLink(value: NavigationDestination.faq) {
                SectionView(iconName: "mingcute_question-line", title: "Вопросы и ответы")
            }
            NavigationLink(value: NavigationDestination.newFeature) {
                SectionView(iconName: "hugeicons_ai-idea", title: "Запросить функцию")
            }
            NavigationLink(value: NavigationDestination.import) {
                SectionView(iconName: "message-outlined", title: "Отправить отзыв")
            }
        }
        .listRowBackground(Color("listColor"))
    }
    
    var dataManagementSection: some View {
        Section(header: Text("Управление данными").textCase(nil).foregroundColor(.gray)) {
            Button(action: {
                // Удаление записей
            }) {
                HStack(spacing: 16) {
                    Image("delete-outline-rounded")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                    Text("Удалить все записи")
                        .foregroundColor(.white)
                    Spacer()
                    Text("(150 KB)")
                        .foregroundColor(.gray)
                }
            }
        }
        .listRowBackground(Color("listColor"))
    }
}
