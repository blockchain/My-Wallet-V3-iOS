// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AVKit
import Combine
import DIKit
import FeatureQRCodeScannerData
import FeatureQRCodeScannerDomain
import FeatureWalletConnectDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

protocol QRCodeScannerViewModelProtocol: AnyObject {
    var scanningStarted: (() -> Void)? { get set }
    var scanningStopped: (() -> Void)? { get set }
    var closeButtonTapped: (() -> Void)? { get set }
    var cameraConfigured: (() -> Void)? { get set }
    /// Displays a bottom sheet with optionally an Allow Camera Access button
    var showInformationSheetTapped: ((Bool) -> Void)? { get set }
    var showCameraAccessFailure: ((_ title: String, _ message: String) -> Void)? { get set }
    var showCameraNotAuthorizedAlert: (() -> Void)? { get set }
    var scanComplete: ((Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void)? { get set }
    var completed: (Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void { get set }

    var videoPreviewLayer: CALayer? { get }
    var headerText: String { get }
    var overlayViewModel: QRCodeScannerOverlayViewModel { get }

    func closeButtonPressed()
    func startReadingQRCode(from scannableArea: QRCodeScannableArea)

    func viewDidAppear()
    func viewWillDisappear()
    func handleSelectedQRImage(_ image: UIImage)

    func showInformationSheet()

    func allowCameraAccess()
    func cameraAccessDenied() -> Bool
    func openAppSettings()
    func showsWalletConnectRow() -> AnyPublisher<Bool, Never>
    func openWalletConnectArticle(url: String)
}

public enum QRCodeScannerParsingOptions {
    /// Strict approach, only act on the link using the given parser
    case strict

    /// Lax parsing, allow acting on other routes at well
    case lax(routes: [DeepLinkRoute])
}

final class QRCodeScannerViewModel: QRCodeScannerViewModelProtocol {
    typealias CompletionHandler = (Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void

    var scanningStarted: (() -> Void)?
    var scanningStopped: (() -> Void)?
    var closeButtonTapped: (() -> Void)?
    var showInformationSheetTapped: ((Bool) -> Void)?
    var cameraConfigured: (() -> Void)?
    var showCameraNotAuthorizedAlert: (() -> Void)?
    var showCameraAccessFailure: ((_ title: String, _ message: String) -> Void)?
    var scanComplete: CompletionHandler?
    var completed: CompletionHandler

    let overlayViewModel: QRCodeScannerOverlayViewModel

    var videoPreviewLayer: CALayer? {
        scanner.videoPreviewLayer
    }

    var headerText: String {
        LocalizationConstants.scanQRCode
    }

    private var hasRunCameraAccessChecks: Bool = false

    private let requestCameraAccess: RequestCameraAccess
    private let checkCameraAccess: () -> AVAuthorizationStatus
    private let types: [QRCodeScannerType]
    private let scanner: QRCodeScannerProtocol
    private let cryptoTargetParser: CryptoTargetQRCodeParser
    private let deepLinkParser: DeepLinkQRCodeParser
    private let secureChannelParser: SecureChannelQRCodeParser
    private let walletConnectParser: WalletConnectQRCodeParser
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let cacheSuite: CacheSuite
    private let urlOpener: URLOpener
    private let parsingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables = [AnyCancellable]()

    init(
        types: [QRCodeScannerType],
        additionalParsingOptions: QRCodeScannerParsingOptions = .strict,
        supportsCameraRoll: Bool,
        scanner: QRCodeScannerProtocol,
        completed: @escaping CompletionHandler,
        requestCameraAccess: @escaping RequestCameraAccess,
        checkCameraAccess: @escaping () -> AVAuthorizationStatus,
        deepLinkHandler: DeepLinkHandling = resolve(),
        deepLinkRouter: DeepLinkRouting = resolve(),
        secureChannelService: SecureChannelAPI = resolve(),
        adapter: CryptoTargetQRCodeParserAdapter = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        walletConnectSessionRepository: SessionRepositoryAPI = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        cacheSuite: CacheSuite = resolve(),
        urlOpener: URLOpener = resolve()
    ) {
        let additionalLinkRoutes: [DeepLinkRoute]
        switch additionalParsingOptions {
        case .lax(routes: let routes):
            additionalLinkRoutes = routes
        case .strict:
            additionalLinkRoutes = []
        }
        let deepLinkQRCodeRouter = DeepLinkQRCodeRouter(
            supportedRoutes: additionalLinkRoutes,
            deepLinkHandler: deepLinkHandler,
            deepLinkRouter: deepLinkRouter
        )
        let sourceAccount: CryptoAccount? = types
            .firstNonNil { type in
                switch type {
                case .cryptoTarget(let sourceAccount):
                    return sourceAccount
                case .deepLink, .walletConnect:
                    return nil
                }
            }

        self.requestCameraAccess = requestCameraAccess
        self.checkCameraAccess = checkCameraAccess
        self.featureFlagsService = featureFlagsService
        self.cacheSuite = cacheSuite
        self.urlOpener = urlOpener

        self.cryptoTargetParser = CryptoTargetQRCodeParser(
            account: sourceAccount,
            adapter: adapter
        )
        self.deepLinkParser = DeepLinkQRCodeParser(deepLinkQRCodeRouter: deepLinkQRCodeRouter)
        self.secureChannelParser = SecureChannelQRCodeParser(secureChannelService: secureChannelService)
        self.walletConnectParser = WalletConnectQRCodeParser()

        self.types = types
        self.scanner = scanner
        self.completed = completed
        self.overlayViewModel = QRCodeScannerOverlayViewModel(
            supportsCameraRoll: supportsCameraRoll,
            titleText: LocalizationConstants.scanQRCode,
            walletConnectSessionRepository: walletConnectSessionRepository,
            featureFlagsService: featureFlagsService,
            analyticsEventRecorder: analyticsEventRecorder
        )

        /// List of parsers in the correct priority.
        let parsers: [QRCodeScannerParsing] = [
            walletConnectParser,
            secureChannelParser,
            cryptoTargetParser,
            deepLinkParser
        ]

        scanner.qrCodePublisher
            .withLatestFrom(parsingSubject.eraseToAnyPublisher()) { ($0, !$1) }
            .filter(\.1)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.parsingSubject.send(true)
            })
            .map { scanResult, _ -> [AnyPublisher<QRCodeScannerResultType?, Never>] in
                parsers.map {
                    $0.parse(scanResult: scanResult)
                        .optional()
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                }
            }
            .flatMap { results -> AnyPublisher<QRCodeScannerResultType?, Never> in
                results
                    .zip()
                    .map { result in
                        result
                            .compactMap { $0 }
                            .first
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { result -> AnyPublisher<QRCodeScannerResultType?, Never> in
                switch result {
                case .cryptoTargets(let targets):
                    return adapter
                        .presentAccountPicker(accounts: targets)
                        .map(QRCodeScannerResultType.cryptoTarget)
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                case .walletConnect:
                    return featureFlagsService
                        .isEnabled(.walletConnectEnabled)
                        .flatMap { isEnabled -> AnyPublisher<QRCodeScannerResultType?, Never> in
                            isEnabled ? .just(result) : .just(nil)
                        }
                        .eraseToAnyPublisher()
                default:
                    return .just(result)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self else {
                    return
                }
                if let result {
                    scanComplete?(.success(result))
                } else {
                    scanComplete?(.failure(.scannerError(QRScannerError.badMetadataObject)))
                    overlayViewModel.scanSuccess.send(.failure(QRScannerError.badMetadataObject))
                    parsingSubject.send(false)
                }
            })
            .store(in: &cancellables)

        parsingSubject
            .eraseToAnyPublisher()
            .dropFirst()
            .sink { [weak self] parsingSubject in
                guard !parsingSubject else {
                    return
                }
                self?.scanner.restartScanning()
            }
            .store(in: &cancellables)
    }

    func viewDidAppear() {
        guard !hasRunCameraAccessChecks else {
            return
        }
        runCameraChecks()
        hasRunCameraAccessChecks = true
    }

    func viewWillDisappear() {
        scanner.stopReadingQRCode(complete: nil)
    }

    func closeButtonPressed() {
        scanner.stopReadingQRCode(complete: nil)
        closeButtonTapped?()
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        scanner.startReadingQRCode(from: scannableArea)
    }

    func handleSelectedQRImage(_ image: UIImage) {
        scanner.handleSelectedQRImage(image)
    }

    func showInformationSheet() {
        let shouldShowAllowAccessButton = checkCameraAccess() == .authorized
        showInformationSheetTapped?(shouldShowAllowAccessButton)
    }

    func allowCameraAccess() {
        switch requestCameraAccess() {
        case .success(let input):
            scanner.configure(with: input)
            cameraConfigured?()
            // displays the informational bottom sheet
            // if not seen before and have already auth'd the camera access
            showAllowAccessSheetIfNeeded()
        case .failure(.notAuthorized):
            showCameraNotAuthorizedAlert?()
        case .failure(let error):
            showCameraAccessFailure?(
                LocalizationConstants.Errors.error,
                String(describing: error)
            )
        }
    }

    func cameraAccessDenied() -> Bool {
        checkCameraAccess() == .denied
    }

    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    func showsWalletConnectRow() -> AnyPublisher<Bool, Never> {
        featureFlagsService.isEnabled(.walletConnectEnabled)
    }

    func openWalletConnectArticle(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        urlOpener.open(url)
    }

    private func runCameraChecks() {
        switch checkCameraAccess() {
        case .notDetermined:
            showInformationSheetTapped?(false)
        case .authorized,
             .denied,
             .restricted:
            allowCameraAccess()
        @unknown default:
            showCameraAccessFailure?(
                LocalizationConstants.Errors.error,
                LocalizationConstants.Errors.genericError
            )
        }
    }

    private func showAllowAccessSheetIfNeeded() {
        guard !cacheSuite.bool(forKey: UserDefaults.Keys.hasSeenAllowAccessInformationSheetKey) else {
            return
        }
        showInformationSheetTapped?(true)
        cacheSuite.set(true, forKey: UserDefaults.Keys.hasSeenAllowAccessInformationSheetKey)
    }
}

extension QRCodeScannerViewModel: QRCodeScannerDelegate {
    func didStartScanning() {
        scanningStarted?()
    }

    func didStopScanning() {
        scanningStopped?()
    }
}
