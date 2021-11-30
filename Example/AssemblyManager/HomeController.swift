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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        CameraManager.shared.cameraOpen(view: self.vPreview)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        CameraManager.shared.cameraStop()
    }
    
    func setupUI() {
        vPreImage.backgroundColor = UIColor(hexString: "#D8D8D8")
    }
    
    @IBAction func cameraCaptured(_ sender: Any) {
        CameraManager.shared.cameraCaptured() { [weak self] (image, error) in
            guard let self = self else { return }
            if let _ = error { return }
            guard let image = image else { return }
            self.vPreImage.image = image
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
}

