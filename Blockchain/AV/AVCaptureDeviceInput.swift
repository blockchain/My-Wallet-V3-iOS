//
//  AVCaptureDeviceInput.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/2/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AVCaptureDeviceError: NSObject, Error {

    @objc enum ErrorType: Int {
        case notAuthorized
        case failedToRetrieveDevice
        case inputError
    }

    let type: ErrorType

    var localizedDescription: String {
        return _description ?? ""
    }

    private let _description: String?

    init(type: ErrorType, description: String? = nil) {
        self.type = type
        self._description = description
    }
}

extension AVCaptureDeviceInput {

    /// Returns an `AVCaptureDeviceInput` to be used for scanning a QR code.
    ///
    /// - Returns: the `AVCaptureDeviceInput` if available, otherwise, nil
    /// - Throws: throws an error if there are any issues with retrieving the `AVCaptureDeviceInput`
    @objc static func deviceInputForQRScanner() throws -> AVCaptureDeviceInput {
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw AVCaptureDeviceError(type: .failedToRetrieveDevice, description: LocalizationConstants.Errors.failedToRetrieveDevice)
        }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                throw AVCaptureDeviceError(type: .notAuthorized)
            }
            throw AVCaptureDeviceError(type: .inputError, description: LocalizationConstants.Errors.inputError)
        }
    }
}
