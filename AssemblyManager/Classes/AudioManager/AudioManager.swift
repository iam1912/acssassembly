//
//  AudioManager.swift
//  AssemblyManager
//
//  Created by apple on 2021/12/1.
//

import UIKit
import AVFoundation

public class AudioManager: NSObject {
    public static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    private var audioPlayFinishCallback: ((Int) -> Void)?
    private var audioPlayObserverCallback: (() -> Void)?
    private var audioStores: [URL] = []
    private var audioCurrentIdentifier: Int = 0
    private var audioFileType: AudioFileType = .local
    private var nsTimer: Timer?
    
    public override init() {
        super.init()
    }
    
    public func setupAudioPlayBack() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions())
        } catch {
        }
    }
    
    public func initAudioPlay(stores: [String], type: AudioFileType, callback: @escaping (Int) -> Void, observerCallback: @escaping () -> Void) {
        self.audioPlayFinishCallback = callback
        self.audioPlayObserverCallback = observerCallback
        observerCallback()
        if stores.count == 0 { return }
        stores.forEach {
            switch type {
            case .local:
                if let path = Bundle.main.path(forResource: $0, ofType: "mp3") {
                    let url = URL(fileURLWithPath: path)
                    self.audioStores.append(url)
                }
            case .remote:
                if let url = URL(string: $0) {
                    self.audioStores.append(url)
                }
            }
        }
        do {
            if let data = NSData(contentsOf: self.audioStores[0]) {
                audioPlayer = try AVAudioPlayer(data: data as Data)
            }
            audioCurrentIdentifier = 0
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
            self.audioPlayFinishCallback?(self.audioCurrentIdentifier)
        } catch {
        }
    }
    
    public func audioPlayNext() {
        self.audioPlayNextOrFront(type: .next)
    }
    
    public func audioPlayFront() {
        self.audioPlayNextOrFront(type: .front)
    }
    
    public func audioPlay() {
        if audioPlayer.duration > 0 {
            audioPlayer.play()
            nsTimer?.invalidate()
            nsTimer = nil
            nsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.audioPlayObserverCallback?()
            }
        }
    }
    
    public func audioPause() {
        audioPlayer.pause()
        nsTimer?.invalidate()
    }
    
    public func audioProcess() -> Float {
        let process = Float(audioPlayer.currentTime / audioPlayer.duration)
        if process.isNaN {
            return 0
        }
        return process
    }
    
    public func audioDuration(places: Int) -> Double {
        let time = Double(audioPlayer.duration / 60)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
    
    public func audioCurrentTime(places: Int) -> Double {
        let time = Double(audioPlayer.currentTime / 60)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
}

extension AudioManager {
    private func audioPlayNextOrFront(type: AudioPlayType) {
        switch type {
        case .front:
            self.audioCurrentIdentifier -= 1
            if self.audioCurrentIdentifier >= 0 && self.audioStores.count > 0 {
                self.audioPlayNextOrFront(identifier: self.audioCurrentIdentifier)
            } else {
                self.audioPause()
            }
        case .next:
            self.audioCurrentIdentifier += 1
            if self.audioCurrentIdentifier >= 0 && self.audioStores.count - 1 >= 0 {
                self.audioPlayNextOrFront(identifier: self.audioCurrentIdentifier)
            } else {
                self.audioPause()
            }
        }
    }
    
    private func audioPlayNextOrFront(identifier: Int) {
        do {
            if let data = NSData(contentsOf: self.audioStores[identifier]) {
                audioPlayer = try AVAudioPlayer(data: data as Data)
                audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
            }
            self.audioPlayer.play()
            self.audioPlayFinishCallback?(self.audioCurrentIdentifier)
        } catch {
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayNextOrFront(type: .next)
        self.audioPlayFinishCallback?(self.audioCurrentIdentifier)
    }
}
