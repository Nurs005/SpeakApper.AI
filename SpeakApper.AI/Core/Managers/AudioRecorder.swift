//
//  AudioRecorder.swift
//  SpeakApper.AI
//
//  Created by Akmaral Ergesh on 08.02.2025.
//

import Foundation
import AVFoundation

final class AudioRecorder: NSObject, ObservableObject {
    @Published var audioLevels: [Float] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var meterTimer: Timer?
    
    private let useCase: RecordingUseCaseProtocol
    
    private(set) var lastRecordedURL: URL?
    private(set) var lastRecordedDuration: TimeInterval?
    var onFinishRecording: (() -> Void)?
    
    var onFinishPlaying: (() -> Void)?
    
    init(useCase: RecordingUseCaseProtocol) {
        self.useCase = useCase
        super.init()
    }
    
    // MARK: - Start
    func startRecording() {
        let fileName = UUID().uuidString + ".m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            startMeterTimer()
            print("Запись начата: \(url.lastPathComponent)")
        } catch {
            print("Ошибка записи: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop
    func stopRecording(delete: Bool = false) {
        audioRecorder?.stop()
        stopMeterTimer()
        
        guard !delete, let recorder = audioRecorder else { return }
        
        let url = recorder.url
        let duration = getDuration(for: url)
        
        lastRecordedURL = url
        lastRecordedDuration = duration
        
        useCase.saveRecording(from: url, duration: duration)
        print("Сохранено через UseCase: \(url.lastPathComponent), \(Int(duration)) сек")
        
        DispatchQueue.main.async {
            self.onFinishRecording?()
        }
    }
    
    // MARK: - Pause / Resume
    func pause() {
        audioRecorder?.pause()
        stopMeterTimer()
        print("Пауза")
    }
    
    func resume() {
        audioRecorder?.record()
        startMeterTimer()
        print("Возобновление")
    }
    
    // MARK: - Delete
    func deleteRecording(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Удалено: \(url.lastPathComponent)")
        } catch {
            print("Ошибка при удалении: \(error.localizedDescription)")
        }
    }
    
    func playRecording(url: URL, completion: @escaping (Bool) -> Void) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            print("Воспроизведение запущено")
            completion(true)
        } catch {
            print("Ошибка воспроизведения: \(error)")
            completion(false)
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        onFinishPlaying?()
    }
    
    // MARK: - Helper
    private func getDuration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
    
    private func normalizedPowerLevel(from decibels: Float) -> Float {
        let minDb: Float = -60
        if decibels < minDb {
            return 0
        }
        return (decibels + abs(minDb)) / abs(minDb)
    }
    
    private func startMeterTimer() {
        audioRecorder?.isMeteringEnabled = true
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            
            let power = recorder.averagePower(forChannel: 0)
            let normalized = self.normalizedPowerLevel(from: power)
            
            DispatchQueue.main.async {
                self.audioLevels.append(normalized)
                if self.audioLevels.count > 30 {
                    self.audioLevels.removeFirst()
                }
            }
        }
    }
    
    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinishPlaying?()
    }
}
