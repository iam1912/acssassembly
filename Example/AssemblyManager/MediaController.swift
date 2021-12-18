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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MediaManager.shared.mediaPlaySingle(view: vPreview, video: "the windy rising", type: .local)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MediaManager.shared.mediaPlayHalfScreen(view: vPreview)
    }
    
    @IBAction func playMedia(_ sender: Any) {
        MediaManager.shared.mediaPlay()
    }
}
