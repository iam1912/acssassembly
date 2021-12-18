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

    public override init() {
        super.init()
        NotificationCenter.default.reinstall(observer: self, name: UIDevice.orientationDidChangeNotification, selector: #selector(orientationChanged(_:)))
    }
    
    @objc private func orientationChanged(_ notification: Notification) {
        if !mediaIsOrientation { return }
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
    
    private func play(view: UIView, url: URL, isAuto: Bool) {
        mediaPlayer = AVPlayer(url: url)
        mediaPlayerLayer.player = mediaPlayer
        setupLayers(view: view, isFullScreen: false)
        if isAuto {
            self.mediaPlayer.play()
        }
    }
    
    private func setupLayers(view: UIView, isFullScreen: Bool) {
        if let oldRootLayer = self.mediaPreview?.layer {
            oldRootLayer.sublayers?.filter{ $0.name == "MediaPlayerLayer" }.forEach{ $0.removeFromSuperlayer() }
        }
        
        mediaPreview = view
        mediaPlayerLayer.name = "MediaPlayerLayer"
        mediaPlayerLayer.videoGravity = .resizeAspectFill
        
        if !isFullScreen {
            mediaPlayerLayer.bounds = view.bounds
            mediaPlayerLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        } else {
            mediaPlayerLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.height, height: view.bounds.width)
            mediaPlayerLayer.position = CGPoint(x: view.bounds.midY, y: view.bounds.midX)
        }
        
        guard let NewRootLayer = self.mediaPreview?.layer else { return }
        NewRootLayer.insertSublayer(self.mediaPlayerLayer, at: 0)
        
        if isFullScreen {
            UIView.animate(withDuration: 0.5) {
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
            self.mediaIsOrientation = true
        } else {
            self.mediaIsOrientation = false
        }
    }
}

// MARK: -- BasicMediaConfig
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
}

// MARK: -- MediaPlay
extension MediaManager {
    //播放
    public func mediaPlay() {
        if self.mediaPlayer.status == .readyToPlay {
            self.mediaPlayer.play()
            self.mediaIsPlayStatus = true
        }
    }
    
    //停止
    public func mediaPasue() {
        self.mediaPlayer.pause()
    }
    
    //横屏play
    public func mediaPlayFullScreen(view: UIView) {
        self.mediaPlayer.pause()
        self.setupLayers(view: view, isFullScreen: true)
        if self.mediaIsPlayStatus {
            self.mediaPlayer.play()
        }
    }
    
    //竖屏play
    public func mediaPlayHalfScreen(view: UIView) {
        if self.mediaPlayerLayer.player == nil { return }
        self.mediaPlayer.pause()
        self.setupLayers(view: view, isFullScreen: false)
        if self.mediaIsPlayStatus {
            self.mediaPlayer.play()
        }
    }
}
