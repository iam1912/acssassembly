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
}

