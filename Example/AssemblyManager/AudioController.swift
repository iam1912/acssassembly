//
//  AudioController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager
import MediaPlayer

class AudioController: PortraitController {
    @IBOutlet weak var vBackWrap: UIView!
    @IBOutlet weak var vSongName: UILabel!
    @IBOutlet weak var vCover: UIImageView!
    @IBOutlet weak var vTotalTime: UILabel!
    @IBOutlet weak var vCurrentTime: UILabel!
    @IBOutlet weak var vPlayOrPause: UIButton!
    @IBOutlet weak var vPlaySlider: UISlider!
    @IBOutlet weak var vVolumeSlider: UISlider!
    
    var stores: [String] = [
        "한(寒) - HANN(Alone in winter)", "화(火花) - HWAA", "MOON", "Where is love", "LOST", "DAHLIA", "Oh my god", "LION", "사랑해 - 爱", "Maybe", "Oh my god (English Ver,)", "Senorita", "What‘s Your Name", "Blow Your Mind", "주세요 - (Give Me Your)", "싫다고 말해 - (Put It Straight)", "LATATA", "MAZE", "알고 싶어 - (想要知晓)", "들어줘요 - (Hear me)", "DON'T TEXT ME", "한 (一) - (HANN)", "Uh-Oh", "Tung-Tung(Empty)", "For You", "DUMDi DUMDi (Japanese ver.)", "HWAA (English Ver.)", "LATATA (English Ver.)", "HWAA(火花) (Chinese Ver.)", "Bonnie & Clyde", "Giant", "Gravity(Live Ver.)", "Why Do You Love Me (Acoustic) (Cover)", "너는 나의 숨이였다 - (你是我的呼吸)", "Missing You", "Shallow (Cover)", "Someone Like You", "Scared To Be Lonely", "바람이 불어오는 곳", "널 사랑하지 않아", "Instagram", "달라-(美元)"
    ]
    var names: [String] = [
        "한(寒) - HANN(Alone in winter)", "화(火花) - HWAA", "MOON", "Where is love", "LOST", "DAHLIA", "Oh my god", "LION", "사랑해 - 爱", "Maybe", "Oh my god (English Ver,)", "Senorita", "What‘s Your Name", "Blow Your Mind", "주세요 - (Give Me Your)", "싫다고 말해 - (Put It Straight)", "LATATA", "MAZE", "알고 싶어 - (想要知晓)", "들어줘요 - (Hear me)", "DON'T TEXT ME", "한 (一) - (HANN)", "Uh-Oh", "Tung-Tung(Empty)", "For You", "DUMDi DUMDi (Japanese ver.)", "HWAA (English Ver.)", "LATATA (English Ver.)", "HWAA(火花) (Chinese Ver.)", "Bonnie & Clyde", "Giant", "Gravity(Live Ver.)", "Why Do You Love Me (Acoustic) (Cover)", "너는 나의 숨이였다 - (你是我的呼吸)", "Missing You", "Shallow (Cover)", "Someone Like You", "Scared To Be Lonely", "바람이 불어오는 곳", "널 사랑하지 않아", "Instagram", "달라-(美元)"
    ]
    var images: [String] = ["ico_burn"]
    var isPlay: Bool = false
    var isPlaySlider: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioInitCallback()
        setupUIAndTarget()
        audioInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AudioManager.shared.audioStarTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        AudioManager.shared.audioStopTimer()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event?.subtype else { return }
        if event == .remoteControlPlay {
            AudioManager.shared.audioPlay()
        } else if event == .remoteControlPause {
            AudioManager.shared.audioPause()
        } else if event == .remoteControlNextTrack {
            AudioManager.shared.audioPlayNext()
        } else if event == .remoteControlPreviousTrack {
            AudioManager.shared.audioPlayFront()
        }
    }
    
    func setupUIAndTarget() {
        vBackWrap.backgroundColor = UIColor(hexString: "#D2D2D2")
        vPlaySlider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        vVolumeSlider.addTarget(self, action: #selector(volumeSliderChanged(_:)), for: .valueChanged)
        vPlaySlider.maximumValue = 1
        vPlaySlider.minimumValue = 0
        vCover.image = UIImage(named: "ico_burn")
        vVolumeSlider.maximumValue = 1
        vVolumeSlider.minimumValue = 0
    }
    
    @IBAction func playFront(_ sender: Any) {
        AudioManager.shared.audioPlayFront()
    }
    
    @IBAction func playNext(_ sender: Any) {
        AudioManager.shared.audioPlayNext()
    }
    
    @IBAction func play(_ sender: Any) {
        self.play()
    }
    
    @IBAction func playLoop(_ sender: Any) {
        AudioManager.shared.audioSetPlayType(type: .loop)
    }
    
    @IBAction func songList(_ sender: Any) {
        let window = UIApplication.shared.keyWindow
        SongListView.show(win: window, stores: self.stores, names: self.names, delegate: self)
    }
}

extension AudioController {
    func audioInitCallback() {
        AudioManager.shared.audioInitCallback() { (i) in
            self.vSongName.text = self.names[i]
            self.vTotalTime.text = "\(AudioManager.shared.audioDuration(places: 2))"
        } observerCallback: {
            self.vPlaySlider.setValue(Float(AudioManager.shared.audioProcess()), animated: true)
            self.vCurrentTime.text = "\(AudioManager.shared.audioCurrentTime(places: 2))"
            self.vVolumeSlider.setValue(AudioManager.shared.audioAolume(), animated: true)
        } lockScreenCallback: { (i) in
            var info = Dictionary<String, Any>()
            info[MPMediaItemPropertyTitle] = self.names[i]
            info[MPMediaItemPropertyArtist] = "(G)I-DLE"
            info[MPMediaItemPropertyAlbumTitle] = "I Burn"
            info[MPMediaItemPropertyAlbumArtist] = "(G)I-DLE"
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named: "ico_burn")!)
            info[MPMediaItemPropertyPlaybackDuration] = AudioManager.shared.audioDuration(places: 2) * 60.0
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioManager.shared.audioCurrentTime(places: 2) * 60.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    func audioInit() {
        AudioManager.shared.audioInitStore(stores: self.stores, type: .local)
    }
    
    func play() {
        self.isPlay = !self.isPlay ? true : false
        if isPlay {
            AudioManager.shared.audioPlay()
            vPlayOrPause.setTitle("暂停", for: .normal)
        } else {
            AudioManager.shared.audioPause()
            vPlayOrPause.setTitle("播放", for: .normal)
        }
    }
    
    @objc func progressSliderChanged(_ sender: UISlider) {
        AudioManager.shared.audioPlaySpecificallyTime(time: Double(sender.value))
        self.vCurrentTime.text = String(format: "%.2f", (Double(sender.value)) * AudioManager.shared.audioDuration(places: 2))
    }
    
    @objc func volumeSliderChanged(_ sender: UISlider) {
        AudioManager.shared.audioSetVolume(volume: sender.value)
    }
}

extension AudioController: SongListDelegate {
    func playSpecificallySong(identifient: Int) {
        AudioManager.shared.audioPlaySpecifically(identifier: identifient)
        self.isPlay = false
        self.play()
    }
}
