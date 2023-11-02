// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureQRCodeScannerDomain
import PlatformKit

public final class SecureChannelQRCodeParser: QRCodeScannerParsing {

    // MARK: Types

    enum ScannerError: LocalizedError {
        case qrCodeIsNotSecureChannel

        var errorDescription: String? {
            switch self {
            case .qrCodeIsNotSecureChannel:
                "Invalid QR Code."
            }
        }
    }

    // MARK: Private Properties

    private let secureChannelService: SecureChannelAPI

    // MARK: Init

    public init(secureChannelService: SecureChannelAPI = resolve()) {
        self.secureChannelService = secureChannelService
    }

    // MARK: QRCodeScannerParsing

    public func parse(scanResult: Result<String, QRScannerError>) -> AnyPublisher<QRCodeScannerResultType, QRScannerError> {
        scanResult
            .flatMap { [secureChannelService] message -> Result<QRCodeScannerResultType, QRScannerError> in
                if secureChannelService.isPairingQRCode(msg: message) {
                    // Scanned QR Code
                    .success(.secureChannel(message))
                } else {
                    // Scanned incorrect QR code.
                    .failure(.parserError(ScannerError.qrCodeIsNotSecureChannel))
                }
            }
            .publisher
            .eraseToAnyPublisher()
    }
}
