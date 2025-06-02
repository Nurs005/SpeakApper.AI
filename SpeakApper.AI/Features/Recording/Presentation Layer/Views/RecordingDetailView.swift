//
//  RecordingDetailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 05.02.2025.
//

import SwiftUI
import AVKit
import Combine

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
    
    // MARK: – Dependencies
    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager
    @ObservedObject var viewModel: RecordingDetailViewModel
    
    // MARK: – Local state
    @State private var showShareSheet      = false
    @State private var playbackRate: Float = 1.0
    @State private var showCustomExport    = false
    @State private var showCopiedAlert     = false
    @State private var showAIActions       = false
    @State private var showLanguagePicker  = false
    
    @FocusState private var isEditingTranscript: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    // MARK: – Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#252528").ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView
                audioPlayerView
                
                Group {
                    if viewModel.isTranscribing {
                        loadingView
                    } else if viewModel.transcriptionText.isEmpty {
                        errorView
                    } else {
                        transcriptionHeaderView
                        transcriptionScrollView
                    }
                }
            }
            .padding(.horizontal)
            
            bottomBar
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.undoManager = undoManager
        }
        
        // MARK: – Sheets & overlays
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
                selectedLanguage: viewModel.selectedLanguage
            ) { lang in
                viewModel.changeLanguage(to: lang)
                showLanguagePicker = false
            }
        }
        .overlay(copiedAlertOverlay)
        .overlay(customExportMenu, alignment: .bottomTrailing)
        .onDisappear { viewModel.stopPlayback() }
        
        // MARK: – Keyboard toolbar (Отмена / Сохранить)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Отмена") {
                    viewModel.revertChanges()
                    isEditingTranscript = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Сохранить") {
                    viewModel.saveTranscription()
                    isEditingTranscript = false
                }
                .fontWeight(.semibold)
            }
        }
        .onReceive(Publishers.keyboardHeight) { height in
            withAnimation {
                self.keyboardHeight = height
            }
        }
    }
    
    // MARK: – Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Назад")
                }
                .font(.system(size: 17, weight: .medium))
            }
            
            Text(viewModel.audioTitle)
                .font(.system(size: 21, weight: .bold))
                .padding(.top, 12)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: – Player + waveform
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
                let barW: CGFloat = 3
                let spacing: CGFloat = 2
                let bars = Int((geo.size.width + spacing) / (barW + spacing))
                
                HStack(spacing: spacing) {
                    ForEach(0..<bars, id: \.self) { _ in
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: barW, height: CGFloat.random(in: 10...22))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(height: 48)
            
            Spacer()
            
            Text(viewModel.audioDuration)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
        
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
            .environment(\.colorScheme, .dark)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color(hex: "#292A33"))
        .cornerRadius(12)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: – Loading / Error
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
        VStack {
            Spacer()
            Text("Не удалось транскрибировать запись.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: – Transcription header
    private var transcriptionHeaderView: some View {
        HStack(spacing: 8) {
            let header = viewModel.lastAIAction
                .map { "AI – \(displayName(for: $0))" }
                ?? "Транскрипция – \(viewModel.selectedLanguage.displayName)"
            
            Text(header)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            if viewModel.lastAIAction == nil {
                Button { showLanguagePicker = true } label: {
                    Image(systemName: "pencil")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    undoManager?.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    undoManager?.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.bottom, 4)
    }
    
    // MARK: – TextEditor + feedback
    private var transcriptionScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $viewModel.transcriptionText)
                        .focused($isEditingTranscript)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .frame(minHeight: 420)
                        .id("Editor")
                }
                .padding(.horizontal)
                .padding(.bottom, keyboardHeight)
            }
            .onChange(of: isEditingTranscript) { editing in
                if editing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("Editor", anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: – Bottom bar
    private var bottomBar: some View {
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
                        Image("cil_copy").font(.system(size: 24))
                    }
                    
                    Button {
                        showCustomExport.toggle()
                    } label: {
                        Image("ph_export").font(.system(size: 24))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#1B1A1A"))
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: – Copied toast
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
    
    // MARK: – Custom export pop-up
    private var customExportMenu: some View {
        Group {
            if showCustomExport {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Отправить как")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    Button("PDF") {
                        export(.pdf)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    Button("MS Word") {
                        export(.word)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    
                    Divider().background(Color.white.opacity(0.15))
                    
                    Button("Текст") {
                        export(.txt)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
                .background(Color(hex: "#303030"))
                .cornerRadius(16)
                .frame(width: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 60 + 8)
                .padding(.trailing, 16)
            }
        }
    }
    
    // MARK: – Helper
    private func displayName(for action: String) -> String {
        switch action {
            case "structurize":     return "Добавить структуру"
            case "summarizePromt":  return "Резюмировать"
            case "frendly":         return "Дружелюбно"
            case "note":            return "Заметка"
            case "bussiness":       return "Бизнес"
            case "blog":            return "Блог"
            case "proffesional":    return "Профессионально"
            case "nefor":           return "Информативно"
            case "song":            return "Песня"
            case "angryBird":       return "Angry Bird"
            default:                return action.capitalized
        }
    }
    
    private func export(_ format: ExportFormat) {
        viewModel.export(format: format)
        showCustomExport = false
    }
}
