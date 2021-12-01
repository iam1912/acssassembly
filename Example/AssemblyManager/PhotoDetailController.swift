//
//  PhotoDetailController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class PhotoDetailController: UIViewController {
    @IBOutlet weak var vPreImage: UIImageView!
    
    var photo = Photo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
    func setData() {
        PhotosManager.shared.phFetchSinglePhotoWithIdentifier(identifier: photo.identifier, size: CGSize(width: H.winWidth() - 40, height: H.winHeight() - 180), isAspect: .none) { (image) in
            self.vPreImage.image = image
        }
    }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePhoto() {
        let image = UIImage(named: "ico_photo")
        if let image = image {
            PhotosManager.shared.pickerSavePhoto(image: image) { (error) in
                if error != nil {
                    H.error("保存失败")
                } else {
                    H.success("保存成功")
                }
            }
        } else {
            H.error("保存失败")
        }
    }
}
