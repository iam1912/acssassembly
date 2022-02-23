//
//  Extension.swift
//  AssemblyManager
//
//  Created by apple on 2021/11/30.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIView {
    func setRoundingCorners(borderColor: UIColor,
                            borderWidth: CGFloat = 1.0,
                            raddi: CGFloat = 4.0,
                            corners: UIRectCorner = [.topLeft, .bottomRight],
                            isDotted: Bool = false) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: raddi, height: raddi))
        // 圆角
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        // 边框
        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        if isDotted {
            borderLayer.lineDashPattern = [NSNumber(value: 4), NSNumber(value: 2)]
        }
        self.layer.addSublayer(borderLayer)
    }
    
    func setGradientLayer(_ startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        gradientlayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        self.layer.masksToBounds = true
        self.layer.insertSublayer(gradientlayer, at: 0)
    }
}

extension UIImage {
    func cgImageCorrectedOrientation() -> CGImage? {
        guard imageOrientation != .up else {
            // This is default orientation, don't need to do anything
            return cgImage
        }
        
        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace,
            let ctx = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        return ctx.makeImage()
    }
    
    func correctedOrientation() -> UIImage? {
        guard let newCGImage = cgImageCorrectedOrientation() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
    
}


extension NotificationCenter {
    public func reinstall(observer: NSObject, name: Notification.Name, selector: Selector) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
}
