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
    private let changeKey = "AVSystemController_SystemVolumeDidChangeNotification"
    
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
    public func audioInitStore(stores: [String], type: AudioFileType, callback: @escaping (Int) -> Void, observerCallback: @escaping () -> Void) {
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
        self.audioPlayFinishCallback = callback
        self.audioPlayObserverCallback = observerCallback
        self.play(identifier: 0, isAuto: false)
    }
    
    //initTimer
    public func audioStarTimer() {
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name(rawValue: changeKey), object: nil)
        self.initNsTimer()
    }
    
    //removeTimer
    public func audioStopTimer() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        self.stopNsTimer()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            self.audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
        }
    }
    
    //播放音乐
    public func audioPlay() {
        if audioPlayer.duration > 0 {
            audioPlayer.play()
        }
    }
    
    //停止播放
    public func audioPause() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        }
    }
    
    //播放下一首
    public func audioPlayNext() {
        self.playNextOrFront(type: .next)
    }
    
    //播放上一首
    public func audioPlayFront() {
        self.playNextOrFront(type: .front)
    }
    
    //播放指定音乐
    public func audioPlaySpecifically(identifier: Int) {
        self.play(identifier: identifier, isAuto: true)
    }
    
    //播放指定时间的音乐
    public func audioPlaySpecificallyTime(time: Double) {
        let isPlaying = self.audioPlayer.isPlaying
        self.audioPause()
        self.audioPlayer.currentTime = time * self.audioPlayer.duration
        if isPlaying {
            self.audioPlay()
        }
    }
    
    //播放方式
    public func audioSetPlayType(type: AudioPlayType) {
        playLoops(type: type)
    }
    
    //
    public func audioSetVolume(volume: Float) {
        self.audioPlayer.volume = volume
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
        return audioPlayer.volume
    }
}

extension AudioManager {
    private func playNextOrFront(type: AudioPlayOrder) {
        switch type {
        case .front:
            self.audioCurrentIdentifier -= 1
            if self.audioCurrentIdentifier >= 0 && self.audioStores.count > 0 {
                self.play(identifier: self.audioCurrentIdentifier, isAuto: true)
            } else {
                self.audioPause()
            }
        case .next:
            self.audioCurrentIdentifier += 1
            if self.audioCurrentIdentifier >= 0 && self.audioStores.count - 1 >= 0 {
                self.play(identifier: self.audioCurrentIdentifier, isAuto: true)
            } else {
                self.audioPause()
            }
        }
    }
    
    private func play(identifier: Int, isAuto: Bool) {
        do {
            if let data = NSData(contentsOf: self.audioStores[identifier]) {
                audioPlayer = try AVAudioPlayer(data: data as Data)
                audioPlayer.delegate = self
                audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
            }
            self.audioPlayFinishCallback?(identifier)
            self.playLoops(type: self.audioPlayType)
            self.audioCurrentIdentifier = identifier
            if isAuto {
                self.audioPlayer.play()
            } else {
                self.audioPlayObserverCallback?()
            }
        } catch {
        }
    }
    
    private func playLoops(type: AudioPlayType) {
        self.audioPlayType = type
        if audioPlayer.isPlaying {
            switch type {
            case .loop:
                self.audioPlayer.numberOfLoops = -1
            case .order:
                self.audioPlayer.numberOfLoops = 0
            }
        }
    }
    
    private func initNsTimer() {
        nsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioPlayObserverCallback?()
        }
    }
    
    private func stopNsTimer() {
        nsTimer?.invalidate()
        nsTimer = nil
    }
    
//    @objc func volumeChanged() {
//        let volume = AVAudioSession.sharedInstance().outputVolume
//        self.audioPlayer.volume = volume
//    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playNextOrFront(type: .next)
    }
}
