// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureQRCodeScannerDomain
import PlatformKit

public final class DeepLinkQRCodeParser: QRCodeScannerParsing {

    // MARK: Types

    enum ScannerError: LocalizedError {
        case qrCodeIsNotDeepLink

        var errorDescription: String? {
            switch self {
            case .qrCodeIsNotDeepLink:
                "Invalid QR Code."
            }
        }
    }

    // MARK: Private Properties

    private let deepLinkQRCodeRouter: DeepLinkQRCodeRouter

    // MARK: Init

    public init(deepLinkQRCodeRouter: DeepLinkQRCodeRouter) {
        self.deepLinkQRCodeRouter = deepLinkQRCodeRouter
    }

    // MARK: QRCodeScannerParsing

    public func parse(scanResult: Result<String, QRScannerError>) -> AnyPublisher<QRCodeScannerResultType, QRScannerError> {
        scanResult
            .flatMap { [deepLinkQRCodeRouter] link -> Result<QRCodeScannerResultType, QRScannerError> in
                if deepLinkQRCodeRouter.routeIfNeeded(using: link) {
                    .success(.deepLink(link))
                } else {
                    .failure(.parserError(ScannerError.qrCodeIsNotDeepLink))
                }
            }
            .publisher
            .eraseToAnyPublisher()
    }
}
