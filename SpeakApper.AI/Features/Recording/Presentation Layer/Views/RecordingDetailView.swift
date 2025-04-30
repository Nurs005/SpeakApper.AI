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

struct RecordingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecordingDetailViewModel

    // MARK: — Состояния
    @State private var showShareSheet = false
    @State private var playbackRate: Float = 1.0
    @State private var showCustomExportMenu = false
    @State private var exportMenuPosition: CGPoint = .zero
    @State private var showCopiedAlert = false
    @State private var showAIActions = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#252528")
                .ignoresSafeArea()

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
            AIActionView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.black.opacity(0.4))
        }

        .onDisappear {
            viewModel.stopPlayback()
        }

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

    // MARK: — Audio Player + menu
    private var audioPlayerView: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.togglePlayPause()
            } label: {
                Circle()
                    .fill(Color(hex: "#6F7CFF"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            HStack(spacing: 2) {
                ForEach(0..<30, id: \.self) { _ in
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: CGFloat.random(in: 10...22))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(viewModel.audioDuration)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.5))

            Menu {
                Button("Поделиться аудио") {
                    showShareSheet = true
                }

                Menu("Скорость воспроизведения") {
                    ForEach([1.0, 1.2, 1.5, 2.0], id: \.self) { rate in
                        Button(action: {
                            playbackRate = Float(rate)
                            viewModel.setPlaybackRate(playbackRate)
                        }) {
                            Label(
                                "\(String(format: "%.1f", rate))×",
                                systemImage: playbackRate == Float(rate) ? "checkmark" : ""
                            )
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    //.rotationEffect(.degrees(90))
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color(hex: "#292A33"))
        .cornerRadius(12)
    }

    // MARK: — Транскрибирование / ошибки / текст
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

    private var transcriptionHeaderView: some View {
        HStack(spacing: 8) {
            Text("Транскрипция - English (авто)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            Spacer()
            HStack(spacing: 16) {
                Image("lets-icons_back")
                Image("lets-icons_right")
            }
            .font(.system(size: 24))
        }
        .padding(.bottom, 4)
    }

    private var transcriptionScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.transcriptionText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                HStack(spacing: 20) {
                    Image(systemName: "hand.thumbsup")
                    Image(systemName: "hand.thumbsdown")
                    Image(systemName: "arrow.clockwise")
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
        }
    }

    // MARK: — Export / Copy / AI
    private var bottomActionsView: some View {
        VStack(spacing: 0) {
            Divider().background(Color.black.opacity(0.3))
            HStack {
                // AI
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
                    // Copy text
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

                    // Export menu trigger
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

    // MARK: — Оверлей для копирования
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

    // MARK: — Меню «Отправить как»
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
}
