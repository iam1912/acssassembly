//
//  SectionInterface.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/11/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

protocol SectionInterface {
    func cellAndData(indexPath: IndexPath) -> UITableViewCell
    func cellRows() -> Int
    func cellHeight(indexPath: IndexPath) -> CGFloat
    func cellDidSelect(indexPath: IndexPath)
    func cellCanEdit(indexPath: IndexPath) -> Bool
    func cellEditing(indexPath: IndexPath, style: UITableViewCell.EditingStyle)
}

extension SectionInterface {
    func cellCanEdit(indexPath: IndexPath) -> Bool {
        return false
    }
    
    func cellEditing(indexPath: IndexPath, style: UITableViewCell.EditingStyle) {
    }
}

protocol CollectionSectionInterface {
    func cellAndData(indexPath: IndexPath) -> UICollectionViewCell
    func cellRows() -> Int
    func cellSize(indexPath: IndexPath) -> CGSize
    func cellDidSelect(indexPath: IndexPath)
    func cellWillDisplay(indexPath: IndexPath)
}

extension CollectionSectionInterface {
    func cellWillDisplay(indexPath: IndexPath) {
    }
}



