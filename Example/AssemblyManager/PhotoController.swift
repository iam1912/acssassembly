//
//  PhotoController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/11/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class PhotoController: PortraitController {
    
    @IBOutlet weak var vPreviewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pickerImage(_ sender: Any) {
        PhotosManager.shared.pickerShowPhoto(controller: self, isAllowEditing: false) { (image) in
            self.vPreviewImage.image = image
        }
    }
}
