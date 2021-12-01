//
//  ViewController.swift
//  AssemblyManager
//
//  Created by iam1912 on 11/30/2021.
//  Copyright (c) 2021 iam1912. All rights reserved.
//

import UIKit
import AssemblyManager

class HomeController: UIViewController {
    @IBOutlet weak var vPreview: UIView!
    @IBOutlet weak var vPreImage: UIImageView!
    @IBOutlet weak var vFlashBtn: UIButton!
    
    var flashMode: FlashMode = .off
    var photo = Photo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotosManager.shared.phRegister() {
            self.setImageForAlbum()
        }
        setupUI()
        setImageForAlbum()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        CameraManager.shared.cameraOpen(view: self.vPreview)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        CameraManager.shared.cameraStop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToPhotoDetail" {
            let controller = segue.destination as? PhotoDetailController
            guard let photo = sender as? Photo else { return }
            controller?.photo = photo
        }
    }
    
    func setupUI() {
        vPreImage.backgroundColor = UIColor(hexString: "#D8D8D8")
    }
    
    func setImageForAlbum() {
        DispatchQueue.main.async {
            PhotosManager.shared.phFetchFirstOrLastPhoto(photoPositionType: .last, size: self.vPreImage.bounds.size) { (photo) in
                    self.photo = photo
                    self.vPreImage.image = photo.image
            }
        }
    }
    
    @IBAction func cameraCaptured(_ sender: Any) {
        CameraManager.shared.cameraCaptured() { [weak self] (image, error) in
            guard self != nil else { return }
            if let _ = error { return }
            guard let image = image else { return }
            PhotosManager.shared.phSavePhoto(image: image) { (error) in
                if error != nil {
                    H.error("保存失败")
                } else {
                }
            }
        }
    }
    
    @IBAction func cameraSwith(_ sender: Any) {
        CameraManager.shared.cameraSwitch()
    }
    
    @IBAction func camerAFlash(_ sender: Any) {
        if self.flashMode == .off {
            CameraManager.shared.cameraFlash(flashMode: .on)
            self.flashMode = .on
            vFlashBtn.setImage(UIImage(named: "ico_flash_on"), for: .normal)
        } else {
            CameraManager.shared.cameraFlash(flashMode: .off)
            self.flashMode = .off
            vFlashBtn.setImage(UIImage(named: "ico_flash_off"), for: .normal)
        }
    }
    
    @IBAction func homeToDetail(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToPhotoDetail", sender: photo)
    }
}

