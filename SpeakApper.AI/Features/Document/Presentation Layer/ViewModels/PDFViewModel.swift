//
//  PDFViewModel.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 21.07.2025.
//



import Foundation
import PDFKit
import Combine

final class PDFViewModel: ObservableObject {
    @Published var document: PDFDocument?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let manager = PDFManager()

    func load(from url: URL) {
        isLoading = true
        errorMessage = nil
        manager.fetchPDF(from: url) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let doc):
                    self?.document = doc
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
