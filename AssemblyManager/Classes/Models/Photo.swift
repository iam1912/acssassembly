//
//  Photo.swift
//  AssemblyManager
//
//  Created by apple on 2021/12/1.
//

import Foundation

public class Photo: NSObject {
    public var image: UIImage = UIImage()
    public var identifier: String = ""
    public var pixelHeight: Int = 0
    public var pixelWidth: Int = 0

    override public init() {}
    
    init(image: UIImage, identifier: String, width: Int, height: Int) {
        self.image = image
        self.identifier = identifier
        self.pixelWidth = width
        self.pixelHeight = height
    }
}
