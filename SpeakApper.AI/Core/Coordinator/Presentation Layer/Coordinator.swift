//
//  Coordinator.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 09.03.2025.
//

import Foundation
import SwiftUI

@Observable
final class Coordinator {
    var path: NavigationPath = NavigationPath()
    var sheet: Sheet?
    var fullscreenCover: FullScreenCover?
    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func presentFullCover(_ cover: FullScreenCover) {
        self.fullscreenCover = cover
    }
    
    func dismissFullCover() {
        self.fullscreenCover = nil
    }
}
