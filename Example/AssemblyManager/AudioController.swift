//
//  AudioController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class AudioController: UIViewController {
    @IBOutlet weak var vBackWrap: UIView!
    @IBOutlet weak var vSongName: UILabel!
    @IBOutlet weak var vCover: UIImageView!
    @IBOutlet weak var vPlayProcess: UIProgressView!
    @IBOutlet weak var vVolumeProcess: UIProgressView!
    @IBOutlet weak var vTotalTime: UILabel!
    @IBOutlet weak var vCurrentTime: UILabel!
    @IBOutlet weak var vPlayOrPause: UIButton!
    
    var stores: [String] = ["한(寒) - HANN(Alone in winter)", "화(火花) - HWAA", "MOON", "Where is love", "LOST", "DAHLIA", "Oh my god", "LION", "사랑해 - 爱", "Maybe", "Oh my god (English Ver,)", "Senorita", "What‘s Your Name", "Blow Your Mind", "주세요 - (Give Me Your)", "싫다고 말해 - (Put It Straight)", "LATATA", "MAZE", "알고 싶어 - (想要知晓)", "들어줘요 - (Hear me)", "DON'T TEXT ME", "한 (一) - (HANN)", "Uh-Oh", "Tung-Tung(Empty)", "For You", "DUMDi DUMDi (Japanese ver.)", "HWAA (English Ver.)", "LATATA (English Ver.)", "HWAA(火花) (Chinese Ver.)", "Bonnie & Clyde", "Giant", "Gravity(Live Ver.)", "Why Do You Love Me (Acoustic) (Cover)", "너는 나의 숨이였다 - (你是我的呼吸)", "Missing You", "Shallow (Cover)", "Someone Like You", "Scared To Be Lonely", "바람이 불어오는 곳", "널 사랑하지 않아", "Instagram", "달라-(美元)"]
    var names: [String] = ["한(寒) - HANN(Alone in winter)", "화(火花) - HWAA", "MOON", "Where is love", "LOST", "DAHLIA", "Oh my god", "LION", "사랑해 - 爱", "Maybe", "Oh my god (English Ver,)", "Senorita", "What‘s Your Name", "Blow Your Mind", "주세요 - (Give Me Your)", "싫다고 말해 - (Put It Straight)", "LATATA", "MAZE", "알고 싶어 - (想要知晓)", "들어줘요 - (Hear me)", "DON'T TEXT ME", "한 (一) - (HANN)", "Uh-Oh", "Tung-Tung(Empty)", "For You", "DUMDi DUMDi (Japanese ver.)", "HWAA (English Ver.)", "LATATA (English Ver.)", "HWAA(火花) (Chinese Ver.)", "Bonnie & Clyde", "Giant", "Gravity(Live Ver.)", "Why Do You Love Me (Acoustic) (Cover)", "너는 나의 숨이였다 - (你是我的呼吸)", "Missing You", "Shallow (Cover)", "Someone Like You", "Scared To Be Lonely", "바람이 불어오는 곳", "널 사랑하지 않아", "Instagram", "달라-(美元)"]
    var images: [String] = ["ico_burn"]
    var isPlay: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vBackWrap.backgroundColor = UIColor(hexString: "#D2D2D2")
        audioInit()
    }
    
    func audioInit() {
        AudioManager.shared.initAudioPlay(stores: self.stores, type: .local) { (i) in
            self.vSongName.text = self.names[i]
            self.vCover.image = UIImage(named: "ico_burn")
            self.vTotalTime.text = "\(AudioManager.shared.audioDuration(places: 2))"
        } observerCallback: {
            self.vPlayProcess.progress = AudioManager.shared.audioProcess()
            self.vCurrentTime.text = "\(AudioManager.shared.audioCurrentTime(places: 2))"
            self.vTotalTime.text = "\(AudioManager.shared.audioDuration(places: 2))"
            self.vVolumeProcess.progress = AudioManager.shared.audioAolume()
        }
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
    
    @IBAction func playLoop(_ sender: Any) {
        AudioManager.shared.audioSetPlayType(type: .loop)
    }
    
    @IBAction func songList(_ sender: Any) {
        let window = UIApplication.shared.keyWindow
        SongListView.show(win: window, stores: self.stores, names: self.names, delegate: self)
    }
}

extension AudioController: SongListDelegate {
    func playSpecificallySong(identifient: Int) {
        AudioManager.shared.audioPlaySpecifically(identifier: identifient)
        self.isPlay = false
        self.play()
    }
}
