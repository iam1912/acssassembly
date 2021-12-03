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
    private var audioPlayType: AudioPlayType = .order
    private var nsTimer: Timer?
    
    public override init() {
        super.init()
    }
    
    //设置后台播放
    public func setupAudioPlayBack() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions())
        } catch {
        }
    }
    
    //初始化播放stores
    public func initAudioPlay(stores: [String], type: AudioFileType, callback: @escaping (Int) -> Void, observerCallback: @escaping () -> Void) {
        nsTimer?.invalidate()
        nsTimer = nil
        nsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioPlayObserverCallback?()
        }
        self.audioPlayFinishCallback = callback
        self.audioPlayObserverCallback = observerCallback
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
            self.audioPlayObserverCallback?()
            self.audioPlayType(type: self.audioPlayType)
            self.audioPlayFinishCallback?(self.audioCurrentIdentifier)
        } catch {
        }
    }
    
    //播放音乐
    public func audioPlay() {
        if audioPlayer.duration > 0 {
            audioPlayer.play()
        }
    }
    
    //播放指定音乐
    public func audioPlaySpecifically(identifier: Int) {
        self.audioCurrentIdentifier = identifier
        self.audioPlayNextOrFront(identifier: identifier)
    }
    
    //播放指定时间的音乐
    public func audioPlaySpecificallyTime(time: Double) {
        self.audioPlayer.play(atTime: TimeInterval(time))
        if !self.audioPlayer.isPlaying {
            self.audioPause()
        }
    }
    
    //播放方式
    public func audioSetPlayType(type: AudioPlayType) {
        self.audioPlayType = type
        audioPlayType(type: type)
    }
    
    private func audioPlayType(type: AudioPlayType) {
        switch type {
        case .loop:
            self.audioPlayer.numberOfLoops = -1
        case .order:
            self.audioPlayer.numberOfLoops = 0
        }
    }
    
    //停止播放
    public func audioPause() {
        audioPlayer.pause()
        nsTimer?.invalidate()
    }
    
    //播放下一首
    public func audioPlayNext() {
        self.audioPlayNextOrFront(type: .next)
    }
    
    //播放上一首
    public func audioPlayFront() {
        self.audioPlayNextOrFront(type: .front)
    }
    
    //播放进度条
    public func audioProcess() -> Float {
        let process = Float(audioPlayer.currentTime / audioPlayer.duration)
        if process.isNaN {
            return 0
        }
        return process
    }
    
    //播放总时间
    public func audioDuration(places: Int) -> Double {
        let time = Double(audioPlayer.duration / 60)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
    
    //播放的当前时间
    public func audioCurrentTime(places: Int) -> Double {
        let time = Double(audioPlayer.currentTime / 60)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
    
    //播放音量
    public func audioAolume() -> Float {
        audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
        return audioPlayer.volume
    }
}

extension AudioManager {
    private func audioPlayNextOrFront(type: AudioPlayOrder) {
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
                self.audioPlayType(type: self.audioPlayType)
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
