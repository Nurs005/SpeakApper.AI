//
//  ImportType.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 16.03.2025.
//

import Foundation

enum ImportType: String, CaseIterable {
    case dictaphone, messengers, files
    
    var title: String {
        switch self {
            case .dictaphone: return "Диктофон"
            case .messengers: return "Мессенджеры"
            case .files: return "Из файлов"
        }
    }
    
    var steps: [ImportStep] {
        switch self {
            case .dictaphone:
                return [
                    ImportStep(imageName: "step1_dictaphone", title: "Шаг 1", description: "Откройте 'Диктофон', выберите аудиозапись"),
                    ImportStep(imageName: "step2_dictaphone", title: "Шаг 2", description: "Нажмите, чтобы поделиться"),
                    ImportStep(imageName: "step3_dictaphone", title: "Шаг 3", description: "Выберите SpeakApper и поделитесь аудио")
                ]
            case .messengers:
                return [
                    ImportStep(imageName: "step1_messenger", title: "Шаг 1", description: "Откройте мессенджер, выберите аудиосообщение"),
                    ImportStep(imageName: "step2_messenger", title: "Шаг 2", description: "Выберите SpeakApper и поделитесь аудио")
                ]
            case .files:
                return [
                    ImportStep(imageName: "step1_files", title: "Шаг 1", description: "Откройте 'Файлы', выберите аудио или голосовой файл и нажмите 'Поделиться'"),
                    ImportStep(imageName: "step2_files", title: "Шаг 2", description: "Выберите SpeakApper и поделитесь аудио")
                ]
        }
    }
}
