//
//  MainViewModel.swift
//  SpeakApper.AI
//
//  Created by Daniyar Merekeyev on 16.02.2025.
//

import Foundation
import Combine

typealias MainDependencies = HasRecordingUseCase

@Observable
final class MainViewModel {
    @ObservationIgnored private let recordingUseCase: RecordingUseCaseProtocol
    @ObservationIgnored private let transcriptionManager: TranscriptionManager
    @ObservationIgnored private(set) var recordingItemsViewModels: [RecordingItemViewModel] = []

    // MARK: — Поиск
    /// Текст для фильтрации записей
    var searchText: String = ""
    /// Отфильтрованные элементы по тексту поиска
    var filteredRecordingItemsViewModels: [RecordingItemViewModel] {
        guard !searchText.isEmpty else {
            return recordingItemsViewModels
        }
        return recordingItemsViewModels.filter { vm in
            vm.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: — Состояния
    var hasRecordings: Bool { !recordingItemsViewModels.isEmpty }
    var hasSubscription: Bool { false /* TODO: реальная логика подписки */ }

    // MARK: — Инициализация
    init(
        dependencies: MainDependencies,
        transcriptionManager: TranscriptionManager = .shared
    ) {
        self.recordingUseCase = dependencies.recordingUseCase
        self.transcriptionManager = transcriptionManager
        reloadRecordings()
    }

    // MARK: — Работа с записями
    func reloadRecordings() {
        let recordings = recordingUseCase.getRecordings()
        self.recordingItemsViewModels = recordings.map { RecordingItemViewModel(model: $0) }
    }

    func appendRecording(_ recording: Recording) {
        let vm = RecordingItemViewModel(model: recording)
        recordingItemsViewModels.insert(vm, at: 0)
    }

    func delete(_ item: RecordingItemViewModel) {
        recordingUseCase.deleteRecording(url: item.model.url)
        recordingItemsViewModels.removeAll { $0.model.url == item.model.url }
    }

    // MARK: — Premium
    func purchasePremium() { /* TODO: StoreKit */ }
    func restorePurchases() { /* TODO: StoreKit.restorePurchases */ }
}
