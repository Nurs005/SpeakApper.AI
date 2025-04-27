//
//  TranscriptionManager.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 12.02.2025.
//

import Foundation
import Speech

class TranscriptionManager: ObservableObject {
    @Published var transcriptions: [URL: String] = [:]
    private let cacheKey = "transcription_cache"

    init() {
        loadCachedTranscriptions()
    }

    // MARK: - Транскрипция аудиофайла
    func transcribeAudio(url: URL, completion: @escaping (String?) -> Void) {
        if let cached = transcriptions[url] {
            print("Используем кэш: \(url.lastPathComponent)")
            completion(cached)
            return
        }

        let recognizer = SFSpeechRecognizer()

        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization { status in
                if status == .authorized {
                    let newRecognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: url)
                    self.startRecognition(with: newRecognizer, request: request, url: url, completion: completion)
                } else {
                    print("Нет разрешения на распознавание речи")
                    completion(nil)
                }
            }
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        startRecognition(with: recognizer, request: request, url: url, completion: completion)
    }

    // MARK: - Начало процесса распознавания
    private func startRecognition(with recognizer: SFSpeechRecognizer?, request: SFSpeechURLRecognitionRequest, url: URL, completion: @escaping (String?) -> Void) {
        recognizer?.recognitionTask(with: request) { result, error in
            if let error = error {
                print("Ошибка транскрипции: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let result = result, result.isFinal {
                let transcription = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcriptions[url] = transcription
                    self.saveTranscriptionToCache(for: url, text: transcription)
                    UserDefaults.standard.set(transcription, forKey: "transcription_\(url.lastPathComponent)") 
                    print("Готово: \(url.lastPathComponent), транскрипция: \(transcription.prefix(50))...")
                    completion(transcription)
                }
            }
        }
    }

    // MARK: - Кеширование транскрипции
    private func saveTranscriptionToCache(for url: URL, text: String) {
        var currentCache = loadRawCache()
        currentCache[url.absoluteString] = text
        UserDefaults.standard.set(currentCache, forKey: cacheKey)
    }

    private func loadCachedTranscriptions() {
        let raw = loadRawCache()
        for (urlString, text) in raw {
            if let url = URL(string: urlString) {
                transcriptions[url] = text
            }
        }
    }

    private func loadRawCache() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: String] ?? [:]
    }

    // MARK: - Запрос авторизации (опционально)
    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
}
