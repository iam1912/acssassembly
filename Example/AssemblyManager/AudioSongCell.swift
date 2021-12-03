//
//  AudioSongCell.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/3.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class AudioSongCell: UICollectionViewCell {
    @IBOutlet weak var vSongName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(name: String) {
        vSongName.text = "\(name) - (G)I-DLE"
    }
}
