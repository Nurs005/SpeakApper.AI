//
//  TranscriptionManager.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 12.02.2025.
//

import Foundation
import Speech
import AVFoundation

final class TranscriptionManager: ObservableObject {
    @Published var transcriptions: [URL: String] = [:]
    private let cacheKey = "transcription_cache"
    private var recognitionTask: SFSpeechRecognitionTask?
    static let shared = TranscriptionManager()
    
    init() {
        loadCachedTranscriptions()
    }
    
    func transcribeAudio(
        url: URL,
        language: String = "",
        completion: @escaping (String?) -> Void
    ) {
        if language.isEmpty {
            transcribeAudioWithFallback(url: url, completion: completion)
        } else {
            transcribeAudioWithFallback(
                url: url,
                locales: [language],
                completion: completion
            )
        }
    }
    
    // MARK: — Попросить разрешение
    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async { completion(status == .authorized) }
        }
    }
    
    // MARK: — Fallback между локалями 
    func transcribeAudioWithFallback(
        url: URL,
        locales: [String] = ["en-US", "ru-RU"],
        completion: @escaping (String?) -> Void
    ) {
        guard !locales.isEmpty else {
            return DispatchQueue.main.async { completion(nil) }
        }
        let locale = locales[0]
        transcribeAudioSingle(url: url, languageCode: locale) { [weak self] text in
            if let text = text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !text.isEmpty {
                return completion(text)
            }
            let remaining = Array(locales.dropFirst())
            self?.transcribeAudioWithFallback(
                url: url,
                locales: remaining,
                completion: completion
            )
        }
    }
    
    // MARK: — Собственно распознавание на одной локали
    private func transcribeAudioSingle(
        url: URL,
        languageCode: String,
        completion: @escaping (String?) -> Void
    ) {
        if let cached = transcriptions[url] {
            print("Кэш для \(url.lastPathComponent)")
            return DispatchQueue.main.async { completion(cached) }
        }
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            return SFSpeechRecognizer.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.transcribeAudioSingle(
                            url: url,
                            languageCode: languageCode,
                            completion: completion
                        )
                    } else {
                        print("Нет прав на распознавание")
                        completion(nil)
                    }
                }
            }
        }
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))
        guard let rec = recognizer, rec.isAvailable else {
            print("SpeechRecognizer недоступен для \(languageCode)")
            return DispatchQueue.main.async { completion(nil) }
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        recognitionTask = rec.recognitionTask(with: request) { [weak self] result, error in
            if let err = error as NSError? {
                print("Ошибка распознавания [\(err.code)]: \(err.localizedDescription)")
                self?.recognitionTask = nil
                return DispatchQueue.main.async { completion(nil) }
            }
            guard let res = result, res.isFinal else { return }
            let text = res.bestTranscription.formattedString
            self?.saveCache(url: url, text: text)
            DispatchQueue.main.async {
                self?.transcriptions[url] = text
                print("Распознано: \(text.prefix(100))…")
                completion(text)
            }
            self?.recognitionTask = nil
        }
    }
    
    // MARK: — Кэширование
    private func saveCache(url: URL, text: String) {
        var raw = UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: String] ?? [:]
        raw[url.lastPathComponent] = text
        UserDefaults.standard.set(raw, forKey: cacheKey)
    }
    
    private func loadCachedTranscriptions() {
        let raw = UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: String] ?? [:]
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first!
        raw.forEach { fileName, text in
            let url = docs.appendingPathComponent(fileName)
            transcriptions[url] = text
        }
    }
    
    func clearCache() {
        transcriptions.removeAll()
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
}
