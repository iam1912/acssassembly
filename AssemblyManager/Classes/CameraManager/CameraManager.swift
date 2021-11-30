//
//  CameraManager.swift
//  AssemblyManager
//
//  Created by apple on 2021/11/30.
//

import UIKit
import AVKit
import AVFoundation

public class CameraManager: NSObject {
    public static let shared = CameraManager()
    
    private var frontPhotoDeviceInput: AVCaptureDeviceInput?
    private var rearPhotoDeviceInput: AVCaptureDeviceInput?
    private var photoDeviceOutput: AVCapturePhotoOutput?
    private var session = AVCaptureSession()
    private var vPreview: AVCaptureVideoPreviewLayer?
    private var positionType: PositionType = .back
    private var imageCallback: ((UIImage?, Error?) -> Void)?
    private var userDidLoginAppleIDCallBack: (() -> Void)?
    private var flashModeEnable: FlashMode = .off

    public override init() {
        super.init()
    }
    
    public class func setup() {
    }

    // 打开摄像头
    public func cameraOpen(view: UIView) {
        self.session = AVCaptureSession()
        self.vPreview = AVCaptureVideoPreviewLayer(session: self.session)
        guard let preview = self.vPreview else { return }
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        self.requestPermission()
    }
    
    // 切换摄像头
    public func cameraSwitch() {
        self.cameraSwitch(positionType: self.positionType == .front ? .back : .front)
    }
    
    // 开始拍照
    public func cameraCaptured(callback: ((UIImage?, Error?) -> Void)? = nil) {
        guard let photoOutput = self.photoDeviceOutput else { return }
        self.imageCallback = callback
        let settings = AVCapturePhotoSettings()
        switch self.flashModeEnable {
        case .off:
            settings.flashMode = .off
        case .on:
            settings.flashMode = .on
        case .auto:
            settings.flashMode = .auto
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // 关闭拍照
    public func cameraStop() {
        self.positionType = .back
        self.flashModeEnable = .off
        self.session.stopRunning()
    }
    
    // 开关闪光灯
    public func cameraFlash(flashMode: FlashMode) {
        self.flashModeEnable = flashMode
    }
}

extension CameraManager {
    private func findInputDevice(positionType: PositionType) -> AVCaptureDevice? {
        let cameraSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let allCameraDevice = cameraSession.devices.compactMap { $0 }
        for cameraDevice in allCameraDevice {
            switch positionType {
            case .front:
                if cameraDevice.position == .front {
                    return cameraDevice
                }
            case .back:
                if cameraDevice.position == .back {
                    return cameraDevice
                }
            }
        }
        return nil
    }
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        // 1. Get device and get capture image size
        guard let device = findInputDevice(positionType: self.positionType) else { return }
        
        // 2. Set Input
        self.rearPhotoDeviceInput = try? AVCaptureDeviceInput(device: device)
        if !session.canAddInput(self.rearPhotoDeviceInput!) { return }
        session.addInput(self.rearPhotoDeviceInput!)
        
        // 3. Set Output
        self.photoDeviceOutput = AVCapturePhotoOutput()
        photoDeviceOutput?.isHighResolutionCaptureEnabled = true
        let captureConnection = photoDeviceOutput?.connection(with: .video)
        captureConnection?.videoOrientation = .portrait
        guard session.canAddOutput(photoDeviceOutput!) else { return }
        session.addOutput(photoDeviceOutput!)
        
        // 4. Commit configure
        session.commitConfiguration()
        self.session.startRunning()
    }
    
    private func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        default:
            return
        }
    }
    
    private func cameraSwitch(positionType: PositionType) {
        guard self.session.isRunning else { return }
        self.positionType = positionType
        session.beginConfiguration()
        switch positionType {
        case .front:
            guard let rearPhotoInput = self.rearPhotoDeviceInput else { return }
            self.session.removeInput(rearPhotoInput)
            guard let device = findInputDevice(positionType: .front) else { return }
            self.frontPhotoDeviceInput = try? AVCaptureDeviceInput(device: device)
            if !session.canAddInput(self.frontPhotoDeviceInput!) { return }
            session.addInput(self.frontPhotoDeviceInput!)
        case .back:
            guard let frontPhotoInput = self.frontPhotoDeviceInput else { return }
            self.session.removeInput(frontPhotoInput)
            guard let device = findInputDevice(positionType: .back) else { return }
            self.rearPhotoDeviceInput = try? AVCaptureDeviceInput(device: device)
            if !session.canAddInput(self.rearPhotoDeviceInput!) { return }
            session.addInput(self.rearPhotoDeviceInput!)
        }
        session.commitConfiguration()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.imageCallback?(nil, error)
            return
        }
        guard let data = photo.fileDataRepresentation() else { return }
        let photo = UIImage(data: data)
        guard let correctImage = photo?.cgImageCorrectedOrientation() else { return }
        let image = UIImage(cgImage: correctImage)
        self.imageCallback?(image, nil)
    }
}

