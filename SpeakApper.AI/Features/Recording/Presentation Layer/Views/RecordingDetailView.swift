//
//  RecordingDetailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

struct LanguagePickerView: View {
    let selectedLanguage: TranscriptionLanguage
    let onSelect: (TranscriptionLanguage) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TranscriptionLanguage.allCases, id: \.self) { lang in
                    Button {
                        onSelect(lang)
                    } label: {
                        HStack {
                            Text(lang.displayName)
                            if lang == selectedLanguage {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Язык голоса на записи")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecordingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecordingDetailViewModel
    
    @State private var showShareSheet = false
    @State private var playbackRate: Float = 1.0
    @State private var showCustomExportMenu = false
    @State private var exportMenuPosition: CGPoint = .zero
    @State private var showCopiedAlert = false
    @State private var showAIActions = false
    @State private var showLanguagePicker = false
    @State private var showOptionsMenu = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#252528").ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView
                audioPlayerView
                
                if viewModel.isTranscribing {
                    loadingView
                } else if viewModel.transcriptionText.isEmpty {
                    errorView
                } else {
                    transcriptionHeaderView
                    transcriptionScrollView
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
            
            bottomActionsView
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [viewModel.audioURL])
        }
        .sheet(isPresented: $showAIActions) {
            AIActionView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationBackground(Color.black.opacity(0.4))
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(
                selectedLanguage: viewModel.selectedLanguage,
                onSelect: { lang in
                    viewModel.changeLanguage(to: lang)
                    showLanguagePicker = false
                }
            )
        }
        .onDisappear { viewModel.stopPlayback() }
        .overlay(copiedAlertOverlay)
        .overlay(customExportMenu)
    }
    
    // MARK: — Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
            }
            
            Text(viewModel.audioTitle)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: — Audio Player + волна + меню
    private var audioPlayerView: some View {
        HStack(spacing: 12) {
            Button { viewModel.togglePlayPause() } label: {
                Circle()
                    .fill(Color(hex: "#6F7CFF"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            
            GeometryReader { geo in
                let barWidth: CGFloat = 3
                let spacing: CGFloat  = 2
                let totalBars = Int((geo.size.width + spacing) / (barWidth + spacing))
                
                HStack(spacing: spacing) {
                    ForEach(0..<totalBars, id: \.self) { _ in
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: barWidth, height: CGFloat.random(in: 10...22))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(height: 48)
            
            Spacer()
            
            Text(viewModel.audioDuration)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.5))
            
            Menu {
                Button("Поделиться аудио") { showShareSheet = true }
                Menu("Скорость воспроизведения") {
                    ForEach([1.0, 1.2, 1.5, 2.0], id: \.self) { rate in
                        Button {
                            playbackRate = Float(rate)
                            viewModel.setPlaybackRate(playbackRate)
                        } label: {
                            Label(
                                String(format: "%.1f×", rate),
                                systemImage: playbackRate == Float(rate) ? "checkmark" : ""
                            )
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                
            }
        }
        .background(Color(hex: "#292A33"))
        .padding(.horizontal, 16)
        .frame(height: 48)
        .cornerRadius(12)
    }
    
    // MARK: — Loading / Error
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#7B87FF")))
                .scaleEffect(1.4)
            Text("Транскрибирование аудиозаписи")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Не удалось транскрибировать запись.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: — Dynamic Header (Language or AI)
    private var transcriptionHeaderView: some View {
        HStack(spacing: 8) {
            let titleText: String = {
                if let action = viewModel.lastAIAction {
                    return "AI – \(displayName(for: action))"
                } else {
                    return "Транскрипция – \(viewModel.selectedLanguage.displayName)"
                }
            }()
            
            Text(titleText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            
            if viewModel.lastAIAction == nil {
                Button { showLanguagePicker = true } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // undo / redo для AI
            HStack(spacing: 16) {
                if viewModel.lastAIAction != nil {
                    Button(action: viewModel.undoAI) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    Button(action: viewModel.redoAI) {
                        Image(systemName: "arrow.uturn.forward")
                    }
                } else {
                    Image("lets-icons_back")
                    Image("lets-icons_right")
                }
            }
            .font(.system(size: 24))
            .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.bottom, 4)
    }
    
    // MARK: — Editable Text + Feedback Icons
    private var transcriptionScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if #available(iOS 16.0, *) {
                    TextEditor(text: $viewModel.transcriptionText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .frame(minHeight: 420)
                } else {
                    TextEditor(text: $viewModel.transcriptionText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .frame(minHeight: 420)
                }
                
                //                HStack(spacing: 20) {
                //                    Image(systemName: "arrow.clockwise")
                //                }
                //                .font(.system(size: 14))
                //                .foregroundColor(.gray)
                
            }
            .padding(.horizontal)
        }
        
    }
    
    // MARK: — Bottom Bar: AI / Copy / Export
    private var bottomActionsView: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black.opacity(0.3))
            
            HStack {
                Button {
                    withAnimation { showAIActions = true }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#6F7CFF"))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button {
                        UIPasteboard.general.string = viewModel.transcriptionText
                        withAnimation { showCopiedAlert = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showCopiedAlert = false }
                        }
                    } label: {
                        Image("cil_copy")
                            .font(.system(size: 24))
                    }
                    
                    GeometryReader { geo in
                        Button {
                            exportMenuPosition = CGPoint(
                                x: geo.frame(in: .global).midX,
                                y: geo.frame(in: .global).maxY
                            )
                            withAnimation { showCustomExportMenu.toggle() }
                        } label: {
                            Image("ph_export")
                                .font(.system(size: 24))
                        }
                        .frame(width: 24, height: 24)
                    }
                    .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#1B1A1A"))
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: — Copied Alert Overlay
    private var copiedAlertOverlay: some View {
        VStack {
            Spacer()
            if showCopiedAlert {
                Text("Текст скопирован")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 80)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCopiedAlert)
    }
    
    // MARK: — Custom Export Menu
    private var customExportMenu: some View {
        Group {
            if showCustomExportMenu {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Отправить как")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    Divider().background(Color.white.opacity(0.15))
                    Button("PDF") {
                        viewModel.export(format: .pdf)
                        showCustomExportMenu = false
                    }
                    .padding()
                    Divider().background(Color.white.opacity(0.15))
                    Button("MS Word") {
                        viewModel.export(format: .word)
                        showCustomExportMenu = false
                    }
                    .padding()
                    Divider().background(Color.white.opacity(0.15))
                    Button("Текст") {
                        viewModel.export(format: .txt)
                        showCustomExportMenu = false
                    }
                    .padding()
                }
                .background(Color(hex: "#303030"))
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(width: 200)
                .position(
                    x: exportMenuPosition.x - 80,
                    y: exportMenuPosition.y - 210
                )
                .animation(.easeInOut, value: showCustomExportMenu)
            }
        }
    }
    
    // MARK: — Helpers
    private func displayName(for action: String) -> String {
        switch action {
            case "structurize":    return "Добавить структуру"
            case "summarizePromt": return "Резюмировать"
            case "frendly":        return "Дружелюбно"
            case "note":           return "Заметка"
            case "bussiness":      return "Бизнес"
            case "blog":           return "Блог"
            case "proffesional":   return "Профессионально"
            case "nefor":          return "Информативно"
            case "song":           return "Песня"
            case "angryBird":      return "Angry Bird"
            default:               return action.capitalized
        }
    }
}

