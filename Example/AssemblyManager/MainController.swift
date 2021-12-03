//
//  MainController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/11/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.tabBar.barTintColor = UIColor(hex: 0x000000, alpha: 0.5)
        var vcs :[UIViewController] = []
        
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNav = homeStoryboard.instantiateViewController(withIdentifier: "HomeController")
        homeNav.tabBarItem.title = "拍照"
        vcs.append(homeNav)
        
        let photoStoryboard = UIStoryboard(name: "Photo", bundle: nil)
        let photoNav = photoStoryboard.instantiateViewController(withIdentifier: "PhotoController")
        photoNav.tabBarItem.title = "相册"
        vcs.append(photoNav)
        
        let audioStoryboard = UIStoryboard(name: "Audio", bundle: nil)
        let audioNav = audioStoryboard.instantiateViewController(withIdentifier: "AudioController")
        audioNav.tabBarItem.title = "音频"
        vcs.append(audioNav)
        
        self.viewControllers = vcs
    }
}
