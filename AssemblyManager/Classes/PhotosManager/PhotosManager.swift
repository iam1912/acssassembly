//
//  PhotosManager.swift
//  AssemblyManager
//
//  Created by apple on 2021/11/30.
//

import UIKit
import Photos

public class PhotosManager: NSObject {
    public static let shared = PhotosManager()
    
    //UIImagePickerController
    private var imagePickerCallback: ((UIImage) -> Void)?
    private var imagePickerSaveFailCallback: ((NSError?) -> Void)?
    private var isAllowEditing: Bool = false
    
    //PHPhotoLibrary
    private var imagePHShowCallback: ((UIImage) -> Void)?
    
    public override init() {
        super.init()
    }
    
    //上传图片 -- UIImagePickerController
    public func pickerShowPhoto(controller: UIViewController, isAllowEditing: Bool, callback: @escaping (UIImage) -> Void) {
        self.imagePickerCallback = callback
        self.isAllowEditing = isAllowEditing
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = isAllowEditing
                controller.present(picker, animated: true)
            }
        }
    }
    
    //保存图片 -- UIImagePickerController
    public func pickerSavePhoto(image: UIImage, callback: @escaping (NSError?) -> Void) {
        self.imagePickerSaveFailCallback = callback
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(handlePickerError(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // 注册PHPhotoLibrary -- PHPhotoLibrary
    public func phRegisterPhoto(callback: @escaping (UIImage) -> Void) {
        self.imagePHShowCallback = callback
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    PHPhotoLibrary.shared().register(self)
                case .notDetermined:
                    return
                case .restricted:
                    return
                case .denied:
                    return
                case .limited:
                    return
                @unknown default:
                    return
                }
            }
        } else {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    // 注销PHPhotoLibrary -- PHPhotoLibrary
    public func phUnregisterPhoto() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // 获取全部图片 -- PHPhotoLibrary
    public func phAllPhotoLibrary(callback: @escaping (PHFetchResult<PHAsset>) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        callback(allPhotos)
    }
    
    // 获取firstOrlast图片 -- PHPhotoLibrary
    public func phFirstOrLastPhotoLibrary(photoPositionType: PhotoPositionType, size: CGSize, callback: @escaping (UIImage) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var photo: PHAsset?
        switch photoPositionType {
        case .first:
            photo = PHAsset.fetchAssets(with: .image, options: allPhotosOptions).firstObject
        case .last:
            photo = PHAsset.fetchAssets(with: .image, options: allPhotosOptions).lastObject
        }
        if let photo = photo {
            phFetchSingleAssets(assets: photo, size: size, callback: callback)
        }
    }
    
    // 加载单张图片 -- PHPhotoLibrary
    public func phFetchSingleAssets(assets: PHAsset, size: CGSize, callback: @escaping (UIImage) -> Void) {
        let imageOption = PHImageRequestOptions()
        imageOption.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: assets, targetSize: size, contentMode: .aspectFit, options: imageOption) { (data: UIImage?, dictionry: Dictionary?) in
            guard let image = data else { return }
            callback(image)
        }
    }
}

extension PhotosManager {
    //UIImagePickerController
    @objc private func handlePickerError(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            self.imagePickerSaveFailCallback?(didFinishSavingWithError)
        } else {
            self.imagePickerSaveFailCallback?(nil)
        }
    }
}

extension PhotosManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var key = UIImagePickerController.InfoKey.originalImage
        if isAllowEditing {
            key = UIImagePickerController.InfoKey.editedImage
        }
        guard let image = info[key] as? UIImage else {
                return
        }
        picker.dismiss(animated: true) {}
        self.imagePickerCallback?(image)
    }
}

extension PhotosManager: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
}
