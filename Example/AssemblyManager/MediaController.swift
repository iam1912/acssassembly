//
//  MediaController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/13.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class MediaController: PortraitController {
    @IBOutlet weak var vPreview: UIView!
    @IBOutlet weak var vTitle: UILabel!
    @IBOutlet weak var vTotalTime: UILabel!
    @IBOutlet weak var vCurrentTime: UILabel!
    @IBOutlet weak var cPreViewHeight: NSLayoutConstraint!
    
    var stores: [String] = []
    var names: [String] = []
    var orientations: UIInterfaceOrientationMask = .portrait
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMediaPlay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MediaManager.shared.mediaPlayHalfOrFullScreen(view: self.vPreview, screenType: .half) {
        }
    }
    
    @IBAction func mediaPlay(_ sender: Any) {
        MediaManager.shared.mediaPlay()
    }
    
    @IBAction func mediaPlayFullScreen(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Media", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MediaPlayController") as! MediaPlayController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupMediaPlay() {
        MediaManager.shared.mediaInitCallback() { i in
            self.vTitle.text = self.names[i]
            self.vTotalTime.text = MediaManager.shared.mediaDuration()
            self.vCurrentTime.text = MediaManager.shared.mediaCurrentTime()
        } mediaSinglePlayEndTimeCallback: {
        }
        MediaManager.shared.addPeriodicTimeObserverCallback {
            self.vCurrentTime.text = MediaManager.shared.mediaCurrentTime()
        }
        MediaManager.shared.mediaInitStores(view: vPreview, stores: stores, type: .local)
    }
}
