//
//  View+CornerRadius.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 16.03.2025.
//

import Foundation
import SwiftUI

struct RoundedCorners: Shape {
    var radius: CGFloat = 30
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
