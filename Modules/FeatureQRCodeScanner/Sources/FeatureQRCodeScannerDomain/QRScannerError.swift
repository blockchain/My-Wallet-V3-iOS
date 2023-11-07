// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum QRScannerError: Error {
    case unknown
    case avCaptureError(AVCaptureDeviceError)
    case badMetadataObject
    case parserError(Error)
}

public enum AVCaptureDeviceError: LocalizedError {
    case notAuthorized
    case failedToRetrieveDevice
    case inputError
    case unknown

    public var errorDescription: String? {
        switch self {
        case .failedToRetrieveDevice:
            LocalizationConstants.Errors.failedToRetrieveDevice
        case .inputError:
            LocalizationConstants.Errors.inputError
        case .notAuthorized:
            nil
        case .unknown:
            nil
        }
    }
}
