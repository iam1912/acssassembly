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
        self.tabBar.barTintColor =  UIColor(hex: 0xFF86B2, alpha: 0.5)

        var vcs :[UIViewController] = []
        
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNav = homeStoryboard.instantiateViewController(withIdentifier: "HomeController")
        homeNav.tabBarItem.title = "主页"
        vcs.append(homeNav)
        
        self.viewControllers = vcs
    }
}
