//
//  LandScapeController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class LandScapeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}
