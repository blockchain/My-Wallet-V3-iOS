//
//  UIDevice+Biometrics.swift
//  Blockchain
//
//  Created by Maurice A. on 7/3/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LocalAuthentication

// TODO: use struct instead of class
@objc class BiometricType: NSObject {

    // MARK: - Properties

    @objc let title: String
    @objc let asset: String

    // MARK: - Initialization

    @available(iOS 11.0, *)
    init?(type: LABiometryType) {
        switch type {
        case .faceID:
            self.title = "Face ID"
            self.asset = "IconFaceID"
        case .touchID:
            self.title = "Touch ID"
            self.asset = "IconTouchID"
        default:
            return nil
        }
    }

    override init() {
        self.title = "Touch ID"
        self.asset = "IconTouchID"
        super.init()
    }
}

// MARK - UIDevice Biometrics Extension

extension UIDevice {
    @objc var supportedBiometricType: BiometricType? {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if #available(iOS 11.0, *) {
                return BiometricType(type: context.biometryType)
            }
            return BiometricType()
        }
        return nil
    }
}
