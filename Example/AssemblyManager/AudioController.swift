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
    @IBOutlet weak var vSongName: UILabel!
    @IBOutlet weak var vCover: UIImageView!
    @IBOutlet weak var vProcess: UIProgressView!
    @IBOutlet weak var vTotalTime: UILabel!
    @IBOutlet weak var vCurrentTime: UILabel!
    @IBOutlet weak var vPlayOrPause: UIButton!
    
    var stores: [String] = ["daliha", "lost", "moon"]
    var name: [String] = ["DAHLIA", "LOST", "MOON"]
    var images: [String] = ["ico_burn"]
    var isPlay: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioInit()
    }
    
    func audioInit() {
        AudioManager.shared.initAudioPlay(stores: self.stores, type: .local) { (i) in
            self.vSongName.text = self.name[i]
            self.vCover.image = UIImage(named: "ico_burn")
            self.vTotalTime.text = "\(AudioManager.shared.audioDuration(places: 2))"
        } observerCallback: {
            self.vProcess.progress = AudioManager.shared.audioProcess()
            self.vCurrentTime.text = "\(AudioManager.shared.audioCurrentTime(places: 2))"
            self.vTotalTime.text = "\(AudioManager.shared.audioDuration(places: 2))"
        }
    }
    
    @IBAction func playFront(_ sender: Any) {
        AudioManager.shared.audioPlayFront()
    }
    
    @IBAction func playNext(_ sender: Any) {
        AudioManager.shared.audioPlayNext()
    }
    
    @IBAction func play(_ sender: Any) {
        if !isPlay {
            AudioManager.shared.audioPlay()
            vPlayOrPause.setTitle("暂停", for: .normal)
            isPlay = true
        } else {
            AudioManager.shared.audioPause()
            vPlayOrPause.setTitle("播放", for: .normal)
            isPlay = false
        }
    }
}
