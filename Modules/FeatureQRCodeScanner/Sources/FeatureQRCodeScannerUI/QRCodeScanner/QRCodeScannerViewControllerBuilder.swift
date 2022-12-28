// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureQRCodeScannerDomain
import Foundation
import PlatformKit
import PlatformUIKit

public enum QRCodeScannerResultError: Error {
    case dismissed
    case scannerError(QRScannerError)
}

public final class QRCodeScannerViewControllerBuilder {
    public typealias CompletionHandler = (Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void

    private var scanner = QRCodeScanner()
    private var loadingViewPresenter: LoadingViewPresenting = resolve()
    private var loadingViewStyle: LoadingViewPresenter.LoadingViewStyle = .activityIndicator
    private var presentationType = QRCodePresentationType.modal(dismissWithAnimation: true)
    private var additionalParsingOptions: QRCodeScannerParsingOptions = .strict
    private var supportsCameraRoll = false

    private let types: [QRCodeScannerType]
    private let completed: CompletionHandler

    public init(
        types: [QRCodeScannerType] = [.cryptoTarget(sourceAccount: nil), .deepLink],
        completed: @escaping CompletionHandler
    ) {
        self.types = types
        self.completed = completed
    }

    public func with(
        loadingViewPresenter: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator
    ) -> QRCodeScannerViewControllerBuilder {
        loadingViewStyle = style
        self.loadingViewPresenter = loadingViewPresenter
        return self
    }

    public func with(presentationType: QRCodePresentationType) -> QRCodeScannerViewControllerBuilder {
        self.presentationType = presentationType
        return self
    }

    public func with(additionalParsingOptions: QRCodeScannerParsingOptions) -> QRCodeScannerViewControllerBuilder {
        self.additionalParsingOptions = additionalParsingOptions
        return self
    }

    public func with(supportForCameraRoll: Bool) -> QRCodeScannerViewControllerBuilder {
        supportsCameraRoll = supportForCameraRoll
        return self
    }

    /// Builds a `UIViewController`.
    /// - Returns: A `UIViewController` or `nil` if the app don't have access to the camera,
    /// an alert will show up automatically asking the user to change the app settings
    public func build() -> UIViewController? {

        let viewModel = QRCodeScannerViewModel(
            types: types,
            additionalParsingOptions: additionalParsingOptions,
            supportsCameraRoll: supportsCameraRoll,
            scanner: scanner,
            completed: completed,
            requestCameraAccess: deviceInputRequest,
            checkCameraAccess: hasAccessToCamera
        )

        let scannerViewController = QRCodeScannerViewController(
            presentationType: presentationType,
            viewModel: viewModel
        )

        switch presentationType {
        case .modal:
            let nav = UINavigationController(rootViewController: scannerViewController)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.isTranslucent = true
            nav.navigationBar.tintColor = .white
            return nav
        case .child:
            return scannerViewController
        }
    }
}
