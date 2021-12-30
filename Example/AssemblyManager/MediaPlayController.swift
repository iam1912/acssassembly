//
//  MediaPlayController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class MediaPlayController: LandScapeController {
    @IBOutlet weak var vPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MediaManager.shared.mediaPlayHalfOrFullScreen(view: self.vPreview, screenType: .full) {
        }
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
}
