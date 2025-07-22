//
//  PDFView.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 21.07.2025.
//

import SwiftUI
import PDFKit


struct PDFScreen: View {
    @StateObject private var viewModel = PDFViewModel()

    let pdfURL: URL

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загружаем PDF...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text("Ошибка: \(error)")
                    .foregroundColor(.red)
            } else if let doc = viewModel.document {
                PDFKitRepresentable(document: doc)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.load(from: pdfURL)
        }
        .navigationTitle("Документ")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct PDFKitRepresentable: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
