//
//  PhotoItemController.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/12/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AssemblyManager

class PhotoItemController: PortraitController {
    @IBOutlet weak var vCollection: UICollectionView!
    
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotosManager.shared.phRegister(callback: {

        })
        let nib = UINib(nibName: "PhotoItemCell", bundle: nil)
        vCollection.register(nib, forCellWithReuseIdentifier: "PhotoItemCell")
        loadData()
    }
    
    func loadData() {
        PhotosManager.shared.phAllPhotos(size: CGSize(width: H.winWidth() / 4, height: H.winWidth() / 4), isAspect: .fill) { (data) in
            self.photos = data
            self.vCollection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoItemToPhotoDetail" {
            let controller = segue.destination as? PhotoDetailController
            guard let photo = sender as? Photo else { return }
            controller?.photo = photo
        }
    }
}

extension PhotoItemController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: H.winWidth() / 4, height: H.winWidth() / 4)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = vCollection.dequeueReusableCell(withReuseIdentifier: "PhotoItemCell", for: indexPath) as! PhotoItemCell
        cell.setData(photo: photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "PhotoItemToPhotoDetail", sender: photos[indexPath.row])
    }
}
