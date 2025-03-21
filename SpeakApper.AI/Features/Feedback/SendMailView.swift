//
//  SendMailView.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 18.03.2025.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    var subject: String
    var messageBody: String
    var recipients: [String]?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        mailVC.setToRecipients(recipients)
        mailVC.setSubject(subject)
        mailVC.setMessageBody(messageBody, isHTML: false)
        return mailVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
