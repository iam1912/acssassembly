//
//  H.swift
//  AssemblyManager_Example
//
//  Created by apple on 2021/11/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class H: NSObject {
    class func error(_ message: String) {
        let alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "cancel")
        alert.show()
    }
    
    class func success(_ message: String) {
        let alert = UIAlertView(title: "Success", message: message, delegate: nil, cancelButtonTitle: "cancel")
        alert.show()
    }
    
    class func winWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class func winHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }

}

