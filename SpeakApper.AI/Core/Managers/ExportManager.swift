//
//  ExportManager.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 20.04.2025.
//

import Foundation
import SwiftUI
import UIKit

final class ExportManager {
    
    static func export(text: String, format: ExportFormat) {
        switch format {
        case .txt:
            exportAsTXT(text)
        case .pdf:
            exportAsPDF(text)
        case .word:
            exportAsWord(text)
        }
    }
    
    private static func exportAsTXT(_ text: String) {
        let fileName = "transcription.txt"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            share(fileURL)
        } catch {
            print("Ошибка при сохранении TXT: \(error.localizedDescription)")
        }
    }
    
    private static func exportAsPDF(_ text: String) {
        let fileName = "transcription.pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let htmlText = "<body style='font-family: -apple-system; font-size: 18px;'>\(text)</body>"
        let formatter = UIMarkupTextPrintFormatter(markupText: htmlText)
        
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) 
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        do {
            try pdfData.write(to: fileURL)
            share(fileURL)
        } catch {
            print("Ошибка при сохранении PDF: \(error.localizedDescription)")
        }
    }
    
    private static func exportAsWord(_ text: String) {
        let fileName = "transcription.rtf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let attributed = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 16)
        ])
        
        do {
            let rtfData = try attributed.data(from: NSRange(location: 0, length: attributed.length),
                                              documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            try rtfData.write(to: fileURL)
            share(fileURL)
        } catch {
            print("Ошибка при сохранении Word (RTF): \(error.localizedDescription)")
        }
    }
    
    private static func share(_ fileURL: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        root.present(activityVC, animated: true)
    }
}
