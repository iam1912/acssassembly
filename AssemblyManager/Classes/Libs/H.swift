//
//  H.swift
//  AssemblyManager
//
//  Created by Yontararak Nicha on 2022/1/30.
//

import UIKit
import StoreKit

public class H: NSObject {
    public class func winWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    public class func winHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public class func calTextHeight(_ text: String,_ font: UIFont, _ width: CGFloat, _ lineHeight: CGFloat = 0) -> CGFloat {
        let textString = text as NSString
        var textAttributes: [String: Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let paragraphStyle = NSMutableParagraphStyle()
        if lineHeight > 0 {
            //paragraphStyle.lineSpacing = 5
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineHeightMultiple = lineHeight / font.lineHeight
            textAttributes[convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle)] = paragraphStyle
        }
        let r = textString.boundingRect(with: CGSize(width: width, height: 500), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(textAttributes), context: nil)
        return max(lineHeight, r.size.height)
    }
    
    public class func calTextWidth(_ text: String, _ size: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        let textAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let r = text.boundingRect(with: CGSize(width: 500, height: 500), options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(textAttributes), context: nil)
        return r.size.width
    }
    
    public func getAttributedString(_ str: String, _ lineSpacing: CGFloat, _ size: CGFloat, _ color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: size), range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    public class func appVersion() -> String {
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(versionString).\(buildString)"
    }
    
    public class func rating() {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        } else {
            guard let url = URL(string: "") else { return }
            UIApplication.shared.open(url, options: [:])
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
