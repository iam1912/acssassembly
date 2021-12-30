//
//  MediaListController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class MediaListController: PortraitController {
    var stores: [String] = ["the windy rising", "Five Hundred Miles", "Lover miss", "My Heart Will Go On", "Shape Of My Heart"]
    var names: [String] = ["起风了", "Five Hundred Miles", "爱人错过", "My Heart Will Go On", "Shape Of My Heart"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayListToPlay" {
            let controller = segue.destination as? MediaController
            controller?.names = self.names
            controller?.stores = self.stores
        }
    }
    
    @IBAction func goToHalfScreen(_ sender: Any) {
        self.performSegue(withIdentifier: "PlayListToPlay", sender: nil)
    }
}
