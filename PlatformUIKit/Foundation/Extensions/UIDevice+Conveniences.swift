//
//  UIDevice+Conveniences.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension UIDevice {
    
    public var type: DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .tv,
             .pad,
             .carPlay,
             .unspecified:
            return .unsupported
        case .phone:
            let size = UIScreen.main.bounds.size
            let height = max(size.width, size.height)
            
            switch height {
            case 568:
                return .iPhoneSE
            case 667:
                return .iPhone8
            case 736:
                return .iPhone8Plus
            case 812:
                return .iPhoneXS
            case 896:
                return .iPhoneXSMax
            default:
                return .unsupported
            }
        }
    }
}

public enum DeviceType {
    case iPhoneSE
    case iPhone8
    case iPhone8Plus
    case iPhoneXS
    case iPhoneXSMax
    case unsupported
    
    public var isPhone: Bool {
        return supportedTypes.contains(self)
    }
    
    /// The `current` device type is at least equal to
    /// the provided version or newer.
    public func isAtLeast(_ this: DeviceType) -> Bool {
        guard this.isPhone else { return false }
        guard let current = supportedTypes.firstIndex(of: self) else { return false }
        guard let minimumRequired = supportedTypes.firstIndex(of: this) else { return false }
        return current >= minimumRequired
    }
    
    /// The `current` device type is older than
    /// the provided version.
    public func isBelow(_ this: DeviceType) -> Bool {
        guard this.isPhone else { return false }
        guard let current = supportedTypes.firstIndex(of: self) else { return false }
        guard let minimumRequired = supportedTypes.firstIndex(of: this) else { return false }
        return current < minimumRequired
    }
    
    /// The `current` device type is newer than
    /// the provided version.
    public func isAbove(_ this: DeviceType) -> Bool {
        guard this.isPhone else { return false }
        guard let current = supportedTypes.firstIndex(of: self) else { return false }
        guard let excluded = supportedTypes.firstIndex(of: this) else { return false }
        return current > excluded
    }
    
    fileprivate var supportedTypes: [DeviceType] {
        return [.iPhoneSE,
                .iPhone8,
                .iPhone8Plus,
                .iPhoneXS,
                .iPhoneXSMax]
    }
}
