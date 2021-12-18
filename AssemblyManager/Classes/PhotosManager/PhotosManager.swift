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
    private var imagePHObserverCallback: (() -> Void)?
    
    public override init() {
        super.init()
    }
    
    //UIImagePickerController
    @objc private func handlePickerError(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            self.imagePickerSaveFailCallback?(didFinishSavingWithError)
        } else {
            self.imagePickerSaveFailCallback?(nil)
        }
    }
    
    // 加载单张图片 -- PHPhotoLibrary
    private func phFetchSinglePhoto(assets: PHAsset, size: CGSize, isAspect: PhotoAspect, callback: @escaping (UIImage) -> Void) {
        let imageOption = PHImageRequestOptions()
        var contentMode: PHImageContentMode = .default
        switch isAspect {
        case .none:
            contentMode = .default
        case .fill:
            contentMode = .aspectFill
        case .fit:
            contentMode = .aspectFit
        }
        if isAspect == .fill {
            imageOption.resizeMode = .exact
            imageOption.normalizedCropRect = .zero
        }
        imageOption.isSynchronous = true
        imageOption.deliveryMode = .highQualityFormat
        PHCachingImageManager.default().requestImage(for: assets, targetSize: size, contentMode: contentMode, options: imageOption) { (data: UIImage?, dictionry: Dictionary?) in
            guard let image = data else { return }
            callback(image)
        }
    }
}

// MARK: -- UIImagePickerController
extension PhotosManager {
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
}

// MARK: -- PHPhotoLibrary
extension PhotosManager {
    // 注册PHPhotoLibrary -- PHPhotoLibrary
    public func phRegister(callback: @escaping () -> Void) {
        self.imagePHObserverCallback = callback
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
    public func phUnregister() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // 获取全部图片 -- PHPhotoLibrary
    public func phAllPhotos(size: CGSize, isAspect: PhotoAspect, callback: @escaping ([Photo]) -> Void) {
        var photoAssets: [Photo] = []
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        allPhotos.enumerateObjects{ (object, index, stop) in
            self.phFetchSinglePhoto(assets: object, size: size, isAspect: isAspect) { (image) in
                let photo = Photo(image: image, identifier: object.localIdentifier, width: object.pixelWidth, height: object.pixelHeight)
                photoAssets.append(photo)
            }
        }
        callback(photoAssets)
    }
    
    // 获取firstOrlast图片 -- PHPhotoLibrary
    public func phFetchFirstOrLastPhoto(photoPositionType: PhotoPositionType, size: CGSize, callback: @escaping (Photo) -> Void) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var asset: PHAsset?
        switch photoPositionType {
        case .first:
            asset = PHAsset.fetchAssets(with: .image, options: allPhotosOptions).firstObject
        case .last:
            asset = PHAsset.fetchAssets(with: .image, options: allPhotosOptions).lastObject
        }
        if let asset = asset {
            phFetchSinglePhoto(assets: asset, size: size, isAspect: .fit) { (image) in
                let photo = Photo(image: image, identifier: asset.localIdentifier, width: asset.pixelWidth, height: asset.pixelHeight)
                callback(photo)
            }
        }
    }
    
    // 通过identifier加载图片 -- PHPhotoLibrary
    public func phFetchSinglePhotoWithIdentifier(identifier: String, size: CGSize, isAspect: PhotoAspect, callback: @escaping (UIImage) -> Void) {
        let identifiers: [String] = [identifier]
        let option = PHFetchOptions()
        let result: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: option)
        guard let asset = result.firstObject else { return }
        phFetchSinglePhoto(assets: asset, size: size, isAspect: isAspect, callback: callback)
    }
    
    // 保存图片 -- PHPhotoLibrary
    public func phSavePhoto(image: UIImage, callback: @escaping (Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: {success, error in
            callback(error)
        })
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
        self.imagePHObserverCallback?()
    }
}
