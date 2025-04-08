//
//  SendMailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 18.03.2025.
//

import SwiftUI
import MessageUI

struct SendMailView: UIViewControllerRepresentable {
    var recipients: [String]
    var subject: String
    var messageBody: String
    var isHTML: Bool = false
    
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode

        init(presentation: Binding<PresentationMode>) {
            _presentation = presentation
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            $presentation.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentationMode)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: isHTML)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
