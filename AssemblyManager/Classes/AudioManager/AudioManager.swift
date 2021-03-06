//
//  AudioManager.swift
//  AssemblyManager
//
//  Created by apple on 2021/12/1.
//

import UIKit
import AVFoundation
import MediaPlayer

public class AudioManager: NSObject {
    public static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    private var audioPlayFinishCallback: ((Int) -> Void)?
    private var audioPlayObserverCallback: (() -> Void)?
    private var audioLockScreenDisplayCallback: ((Int) -> Void)?
    private var audioStores: [URL] = []
    private var audioCurrentIdentifier: Int = 0
    private var audioFileType: AudioFileType = .local
    private var audioPlayType: AudioPlayType = .order
    private var nsTimer: Timer?
    
    public override init() {
        super.init()
    }
    
    private func playNextOrFront(type: AudioPlayOrder) {
        switch type {
        case .front:
            if self.audioCurrentIdentifier == 0 {
                self.play(identifier: self.audioStores.count - 1, isAuto: true)
            } else {
                self.play(identifier: self.audioCurrentIdentifier - 1, isAuto: true)
            }
        case .next:
            if self.audioCurrentIdentifier == self.audioStores.count - 1 && self.audioStores.count >= 1 {
                self.play(identifier: 0, isAuto: true)
            } else {
                self.play(identifier: self.audioCurrentIdentifier + 1, isAuto: true)
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
            self.audioCurrentIdentifier = identifier
            self.playLoops(type: audioPlayType)
            self.audioPlayFinishCallback?(identifier)
            self.audioLockScreenDisplayCallback?(identifier)
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
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            self.audioPause()
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                self.audioPlay()
            }
        }
    }
    
    @objc private func HandleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.RouteChangeReason(rawValue: typeValue) else {
                    return
        }
        if type == .newDeviceAvailable {
            return
        } else if type == .oldDeviceUnavailable {
            guard let route = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else { return }
            let outputType = route.outputs[0].portType
            if outputType == .headphones {
                if self.audioPlayer.isPlaying {
                    self.audioPlay()
                }
            }
        }
    }
    
    //???????????????????????????
    private func audioHandleInterruption() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }
    
    //????????????????????????
    private func audioHandleRouteChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(HandleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            self.audioPlayer.volume = AVAudioSession.sharedInstance().outputVolume
        }
    }
}

// MARK: -- Play
extension AudioManager {
    //????????????
    public func audioPlay() {
        if audioPlayer.duration > 0 {
            audioPlayer.play()
        }
    }
    
    //????????????
    public func audioPause() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            audioLockScreenDisplayCallback?(self.audioCurrentIdentifier)
        }
    }
    
    //???????????????
    public func audioPlayNext() {
        self.playNextOrFront(type: .next)
    }
    
    //???????????????
    public func audioPlayFront() {
        self.playNextOrFront(type: .front)
    }
    
    //??????????????????????????????
    public func audioPlaySpecifyForList(identifier: Int) {
        self.play(identifier: identifier, isAuto: true)
    }
    
    //??????????????????
    public func audioPlayRandom(identifier: String, type: AudioFileType, callback: @escaping (Int) -> Void) {
        var playURL: URL?
        if type == .local {
            if let path = Bundle.main.path(forResource: identifier, ofType: "mp3") {
                playURL = URL(fileURLWithPath: path)
            }
        } else if type == .remote {
            playURL = URL(string: identifier)
        }
        if let url = playURL {
            if !self.audioStores.contains(url) {
                self.audioCurrentIdentifier += 1
                self.audioStores.insert(url, at: self.audioCurrentIdentifier)
                callback(self.audioCurrentIdentifier)
                self.play(identifier: self.audioCurrentIdentifier, isAuto: true)
            }
        }
    }
    
    //???????????????????????????
    public func audioPlaySpecifyTime(time: Double) {
        let isPlaying = self.audioPlayer.isPlaying
        self.audioPause()
        self.audioPlayer.currentTime = time * self.audioPlayer.duration
        if isPlaying {
            self.audioPlay()
        }
    }
    
    //????????????
    public func audioSetPlayType(type: AudioPlayType) {
        playLoops(type: type)
    }
    
    //????????????
    public func audioSetVolume(volume: Float) {
        self.audioPlayer.volume = volume
    }
    
    //???????????????
    public func audioProcess() -> Float {
        let process = Float(audioPlayer.currentTime / audioPlayer.duration)
        if process.isNaN {
            return 0
        }
        return process
    }
    
    //???????????????
    public func audioDuration(places: Int) -> Double {
        let time = Double(audioPlayer.duration / 60.0)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
    
    //?????????????????????
    public func audioCurrentTime(places: Int) -> Double {
        let time = Double(audioPlayer.currentTime / 60.0)
        let divisor = pow(10.0, Double(places))
        return (time * divisor).rounded() / divisor
    }
    
    //????????????
    public func audioAolume() -> Float {
        return audioPlayer.volume
    }
    
    //????????????
    public func audioPlayStatus() -> Bool {
        return audioPlayer.isPlaying
    }
}

// MARK: -- BasicPlayConfig
extension AudioManager {
    //??????????????????
    public func setupAudioPlayBack() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
        }
        self.audioHandleInterruption()
        self.audioHandleRouteChange()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    //?????????callback????????????audioInitStore????????????callback
    public func audioInitCallback(finishCallback: @escaping (Int) -> Void, observerCallback: @escaping () -> Void, lockScreenCallback: @escaping (Int) -> Void) {
        self.audioPlayFinishCallback = finishCallback
        self.audioPlayObserverCallback = observerCallback
        self.audioLockScreenDisplayCallback = lockScreenCallback
    }
    
    //???????????????stores
    public func audioInitStore(stores: [String], type: AudioFileType, identifier: Int = 0) {
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
        self.play(identifier: 0, isAuto: false)
    }
    
    //initTimer
    public func audioStarTimer() {
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
        self.initNsTimer()
    }
    
    //removeTimer
    public func audioStopTimer() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        self.stopNsTimer()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playNextOrFront(type: .next)
    }
}
