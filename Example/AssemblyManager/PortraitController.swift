//
//  PortraitController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class PortraitController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
