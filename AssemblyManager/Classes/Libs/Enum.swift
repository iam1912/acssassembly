//
//  Enum.swift
//  AssemblyManager
//
//  Created by apple on 2021/11/30.
//

import Foundation

//Camera
public enum PositionType: Int {
    case front
    case back
}

public enum FlashMode {
    case auto
    case on
    case off
}

public enum PhotoPositionType {
    case first
    case last
}

//Photo
public enum PhotoAspect {
    case fill
    case fit
    case none
}

//Audio
public enum AudioPlayType {
    case front
    case next
}

public enum AudioFileType {
    case local
    case remote
}
