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
        var vcs :[UIViewController] = []
        
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNav = homeStoryboard.instantiateViewController(withIdentifier: "HomeController")
        homeNav.tabBarItem.title = "拍照"
        vcs.append(homeNav)
        
        let photoStoryboard = UIStoryboard(name: "Photo", bundle: nil)
        let photoNav = photoStoryboard.instantiateViewController(withIdentifier: "PhotoController")
        photoNav.tabBarItem.title = "相册"
        vcs.append(photoNav)
        
        self.viewControllers = vcs
    }
}
