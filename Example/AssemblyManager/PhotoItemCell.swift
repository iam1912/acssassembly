//
//  PhotoItemCell.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class PhotoItemCell: UICollectionViewCell {
    @IBOutlet weak var vPhoto: UIImageView!
    
    var photo = Photo()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(photo: Photo) {
        self.photo = photo
        vPhoto.image = photo.image
    }
}
