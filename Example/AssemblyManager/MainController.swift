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
        homeNav.tabBarItem.title = "Camera"
        vcs.append(homeNav)
        
        let photoStoryboard = UIStoryboard(name: "Photo", bundle: nil)
        let photoNav = photoStoryboard.instantiateViewController(withIdentifier: "PhotoController")
        photoNav.tabBarItem.title = "Photo"
        vcs.append(photoNav)
        
        let audioStoryboard = UIStoryboard(name: "Audio", bundle: nil)
        let audioNav = audioStoryboard.instantiateViewController(withIdentifier: "AudioController")
        audioNav.tabBarItem.title = "Music"
        vcs.append(audioNav)
        
        let mediaStoryboard = UIStoryboard(name: "Media", bundle: nil)
        let mediaNav = mediaStoryboard.instantiateViewController(withIdentifier: "MediaListController")
        mediaNav.tabBarItem.title = "Video"
        vcs.append(mediaNav)
        
        self.viewControllers = vcs
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }

    override var shouldAutorotate: Bool {
        return self.selectedViewController?.shouldAutorotate ?? false
    }
}
