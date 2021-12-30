//
//  MediaManager.swift
//  AssemblyManager
//
//  Created by apple on 2021/12/13.
//

import UIKit
import AVFoundation

public class MediaManager: NSObject {
    public static let shared = MediaManager()
    
    private var mediaPlayer: AVPlayer = AVPlayer()
    private var detectionOverlay: CALayer! = nil
    private var mediaPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    private var mediaPreview: UIView?
    private var mediaStores: [URL] = []
    private var mediaCurrentIdentifier: Int = 0
    private var mediaIsOrientation: Bool = false
    private var mediaIsPlayStatus: Bool = false
    private var mediaIsPlayList: Bool = false
    
    private var mediaListPlayEndTimeCallback: ((Int) -> Void)?
    private var mediaSinglePlayEndTimeCallback: (() -> Void)?
    private var mediaPeriodicTimeObserverCallback: (() -> Void)?

    public override init() {
        super.init()
        NotificationCenter.default.reinstall(observer: self, name: UIDevice.orientationDidChangeNotification, selector: #selector(orientationChanged(_:)))
        NotificationCenter.default.reinstall(observer: self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, selector: #selector(playEndTime(_:)))
    }
    
    @objc private func orientationChanged(_ notification: Notification) {
        if !self.mediaIsOrientation { return }
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .landscapeRight {
            UIView.animate(withDuration: 0.5) {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        } else if deviceOrientation == .landscapeLeft {
            UIView.animate(withDuration: 0.5) {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
    }
    
    @objc private func playEndTime(_ notification: Notification) {
        if self.mediaIsPlayList {
            self.mediaCurrentIdentifier += 1
            if self.mediaCurrentIdentifier <= self.mediaStores.count {
                guard let view = self.mediaPreview else { return }
                self.play(view: view, url: self.mediaStores[mediaCurrentIdentifier], isAuto: true)
            } else if self.mediaCurrentIdentifier > self.mediaStores.count || self.mediaCurrentIdentifier < 0 {
                self.mediaPasue()
            }
        } else {
            
        }
    }
    
    private func startPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.mediaPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.mediaPeriodicTimeObserverCallback?()
        }
    }
    
    private func play(view: UIView, url: URL, isAuto: Bool) {
        self.mediaPlayer = AVPlayer(url: url)
        self.mediaPlayerLayer.player = self.mediaPlayer
        self.setupLayers(view: view, screenType: .half)
        self.startPeriodicTimeObserver()
        if isAuto {
            self.mediaPlayer.play()
        }
        if self.mediaIsPlayList {
            self.mediaListPlayEndTimeCallback?(mediaCurrentIdentifier)
        } else {
        }
    }
    
    private func setupLayers(view: UIView, screenType: MediaScreen) {
        if let oldRootLayer = self.mediaPreview?.layer {
            oldRootLayer.sublayers?.filter{ $0.name == "MediaPlayerLayer" }.forEach{ $0.removeFromSuperlayer() }
        }
        self.mediaPreview = view
        self.mediaPlayerLayer.name = "MediaPlayerLayer"
        self.mediaPlayerLayer.videoGravity = .resizeAspectFill
        if screenType == .half {
            self.mediaPlayerLayer.bounds = view.bounds
            self.mediaPlayerLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        } else if screenType == .full {
            self.mediaPlayerLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.height, height: view.bounds.width)
            self.mediaPlayerLayer.position = CGPoint(x: view.bounds.midY, y: view.bounds.midX)
        }
        guard let newRootLayer = self.mediaPreview?.layer else { return }
        newRootLayer.insertSublayer(self.mediaPlayerLayer, at: 0)
        if screenType == .full {
            UIView.animate(withDuration: 0.5) {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
    }
    
    private func formatTime(time: CMTime) -> String {
        let timeSec = CMTimeGetSeconds(time)
        if timeSec.isNaN {
            return "00:00"
        }
        return String(format: "%02zd:%02zd", Int(timeSec / 60),
                      Int(timeSec.truncatingRemainder(dividingBy: 60.0)))
    }
}

// MARK: -- BasicMediaConfig
extension MediaManager {
    //初始化callback
    public func mediaInitCallback(mediaListPlayEndTimeCallback: @escaping (Int) -> Void, mediaSinglePlayEndTimeCallback:  @escaping () -> Void) {
        self.mediaListPlayEndTimeCallback = mediaListPlayEndTimeCallback
        self.mediaSinglePlayEndTimeCallback = mediaSinglePlayEndTimeCallback
    }
    
    public func addPeriodicTimeObserverCallback(callback: @escaping () -> Void) {
        self.mediaPeriodicTimeObserverCallback = callback
    }
}

// MARK: -- MediaPlay
extension MediaManager {
    //播放连续video
    public func mediaInitStores(view: UIView, stores: [String], type: MediaFileType) {
        if stores.count == 0 { return }
        stores.forEach {
            switch type {
            case .local:
                if let path = Bundle.main.path(forResource: $0, ofType: "mp4") {
                    let url = URL(fileURLWithPath: path)
                    self.mediaStores.append(url)
                }
            case .remote:
                if let url = URL(string: $0) {
                    self.mediaStores.append(url)
                }
            }
        }
        self.mediaIsPlayList = true
        self.mediaCurrentIdentifier = 0
        self.play(view: view, url: self.mediaStores[0], isAuto: false)
    }
    
    //播放单个video
    public func mediaPlaySingle(view: UIView, video: String, type: MediaFileType) {
        switch type {
        case .local:
            if let path = Bundle.main.path(forResource: video, ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
                self.play(view: view, url: url, isAuto: false)
            }
        case .remote:
            if let url = URL(string: video) {
                self.play(view: view, url: url, isAuto: false)
            }
        }
    }
    
    //播放
    public func mediaPlay() {
        if self.mediaPlayer.status == .readyToPlay {
            self.mediaPlayer.play()
            self.mediaIsPlayStatus = true
        }
        if self.mediaIsPlayList {
            self.mediaListPlayEndTimeCallback?(mediaCurrentIdentifier)
        }
    }
    
    //停止
    public func mediaPasue() {
        self.mediaPlayer.pause()
        self.mediaIsPlayStatus = false
    }
    
    //横屏or竖屏
    public func mediaPlayHalfOrFullScreen(view: UIView,  screenType: MediaScreen, callback: @escaping () -> Void) {
        self.mediaPlayer.pause()
        self.setupLayers(view: view, screenType: screenType)
        if self.mediaIsPlayStatus {
            self.mediaPlayer.play()
        }
        callback()
    }
    
    //播放总时间
    public func mediaDuration() -> String {
        guard let totalTime = self.mediaPlayer.currentItem?.duration else { return "00:00" }
        return self.formatTime(time: totalTime)
    }
    
    //播放的当前时间
    public func mediaCurrentTime() -> String {
        guard let playTime = self.mediaPlayer.currentItem?.currentTime() else { return "00:00" }
        return self.formatTime(time: playTime)
    }
}
