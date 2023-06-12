//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import BlockchainComponentLibrary
import FeatureQRCodeScannerDomain
import FeatureQRCodeScannerUI
import FeatureTransactionUI
import FeatureWalletConnectDomain
import Localization
import PlatformUIKit
import SwiftUI
import ToolKit

public struct QRCodeScannerView: UIViewControllerRepresentable {

    private let app: AppProtocol
    private let secureChannelRouter: SecureChannelRouting
    private let walletConnectService: WalletConnectVersionRouter
    private let tabSwapping: TabSwapping

    public init(
        app: AppProtocol,
        secureChannelRouter: SecureChannelRouting,
        walletConnectService: WalletConnectVersionRouter,
        tabSwapping: TabSwapping
    ) {
        self.app = app
        self.secureChannelRouter = secureChannelRouter
        self.walletConnectService = walletConnectService
        self.tabSwapping = tabSwapping
    }

    public func makeUIViewController(context: Context) -> some UIViewController {

        let builder = QRCodeScannerViewControllerBuilder(
            completed: { result in
                guard case .success(let success) = result else {
                    return
                }

                switch success {
                case .secureChannel(let message):
                    secureChannelRouter.didScanPairingQRCode(msg: message)
                case .cryptoTarget(let target):
                    switch target {
                    case .address(let account, let address):
                        tabSwapping.send(from: account, target: address)
                    case .bitpay:
                        break
                    }
                case .walletConnect(let url):
                    Task(priority: .userInitiated) {
                        do {
                            try await walletConnectService.pair(uri: url)
                        } catch {
                            app.post(error: error)
                        }
                    }
                case .deepLink, .cryptoTargets:
                    break
                }
            }
        )

        guard let viewController = builder.build() else {
            return UIHostingController(
                rootView: PrimaryNavigationView {
                    ActionableView(
                        .init(
                            media: .image(named: "circular-error-icon", in: .platformUIKit),
                            title: LocalizationConstants.noCameraAccessTitle,
                            subtitle: LocalizationConstants.noCameraAccessMessage
                        )
                    )
                    .primaryNavigation(title: LocalizationConstants.scanQRCode) {
                        IconButton(icon: .closeCirclev2) {
                            context.environment.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            ) as UIViewController
        }

        return viewController as UIViewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
