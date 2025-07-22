//
//  PDFManager.swift
//  SpeakApper.AI
//
//  Created by Nurtileu Amanzhol on 21.07.2025.
//

import Foundation
import PDFKit

final class PDFManager {
    func fetchPDF(from url: URL, completion: @escaping (Result<PDFDocument, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let document = PDFDocument(data: data) else {
                completion(.failure(NSError(domain: "PDF", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF data"])))
                return
            }

            completion(.success(document))
        }
        task.resume()
    }
}
