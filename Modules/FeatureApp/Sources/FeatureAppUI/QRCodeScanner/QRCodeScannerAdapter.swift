// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureQRCodeScannerDomain
import FeatureQRCodeScannerUI
import FeatureTransactionDomain
import FeatureTransactionUI
import PlatformKit
import PlatformUIKit
import UIComponentsKit

final class QRCodeScannerAdapter {

    enum QRScannerAdapterError: Error {
        case noAccountSelected
    }

    private let accountPickerAccountProvider: AccountPickerAccountProviding
    private let navigationRouter: NavigationRouterAPI
    private let payloadFactory: CryptoTargetPayloadFactoryAPI
    private let qrCodeScannerRouter: QRCodeScannerRouting
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private var router: AccountPickerRouting?
    private var accountPickerBridge: QRCodeScannerAccountPickerBridge?
    private var cancellables = Set<AnyCancellable>()

    init(
        qrCodeScannerRouter: QRCodeScannerRouting,
        payloadFactory: CryptoTargetPayloadFactoryAPI,
        topMostViewControllerProvider: TopMostViewControllerProviding,
        navigationRouter: NavigationRouterAPI
    ) {
        self.qrCodeScannerRouter = qrCodeScannerRouter
        self.payloadFactory = payloadFactory
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.navigationRouter = navigationRouter
        self.accountPickerAccountProvider = AccountPickerAccountProvider(
            action: .send,
            failSequence: false
        )
    }
}

extension QRCodeScannerAdapter: QRCodeScannerLinkerAPI {
    func presentQRCodeScanner(
        account: CryptoAccount,
        completion: @escaping (Result<CryptoTargetQRCodeParserTarget, Error>) -> Void
    ) {
        let builder = QRCodeScannerViewControllerBuilder(
            types: [.cryptoTarget(sourceAccount: account)],
            completed: { result in
                switch result {
                case .success(.cryptoTarget(let target)):
                    completion(.success(CryptoTargetQRCodeParserTarget(target: target)))
                case .success:
                    completion(.failure(QRScannerError.unknown))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )

        guard let viewController = builder.build() else {
            // No camera access, an alert will be displayed automatically.
            return
        }

        topMostViewControllerProvider
            .topMostViewController?
            .present(
                viewController,
                animated: true
            )
    }
}

extension QRCodeScannerAdapter: CryptoTargetQRCodeParserAdapter {
    var availableAccounts: AnyPublisher<[BlockchainAccount], QRScannerError> {
        accountPickerAccountProvider
            .accounts
            .asPublisher()
            .mapError(QRScannerError.parserError)
            .eraseToAnyPublisher()
    }

    func presentAccountPicker(
        accounts: [QRCodeParserTarget]
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError> {
        /// Creates a QRCodeScannerAccountPickerBridge and connects its events to this Adapter.
        let accountPickerBridge = QRCodeScannerAccountPickerBridge(targets: accounts)
        accountPickerBridge.events
            .sink { [weak self] event in
                self?.handleAccountPickerBridge(event: event)
            }
            .store(in: &cancellables)
        self.accountPickerBridge = accountPickerBridge

        let builder = AccountPickerBuilder(
            accountProvider: accountPickerBridge,
            action: .send
        )

        let router = builder.build(
            listener: .listener(accountPickerBridge),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(),
            headerModel: .none
        )

        self.router = router
        router.interactable.activate()
        router.load()
        let viewController = router.viewControllable.uiviewController
        viewController.isModalInPresentation = true

        navigationRouter.present(viewController: viewController)

        return accountPickerBridge.selectedTarget
    }

    func create(
        fromString string: String?,
        account: CryptoAccount
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError> {
        payloadFactory
            .create(fromString: string, asset: account.asset)
            .map { target in
                QRCodeParserTarget(account: account, target: target)
            }
            .mapError(QRScannerError.parserError)
            .eraseToAnyPublisher()
    }

    func createAndValidate(
        fromString string: String?,
        account: CryptoAccount
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError> {
        payloadFactory
            .create(fromString: string, asset: account.asset)
            .map { target in
                QRCodeParserTarget(account: account, target: target)
            }
            .mapError(QRScannerError.parserError)
            .flatMap { target -> AnyPublisher<QRCodeParserTarget, QRScannerError> in
                switch target {
                case .bitpay(let address):
                    BitPayInvoiceTarget
                        .make(from: address, asset: account.asset)
                        .map { target in
                            FeatureQRCodeScannerDomain
                                .QRCodeParserTarget
                                .address(account, target)
                        }
                        .mapError(QRScannerError.parserError)
                        .eraseToAnyPublisher()
                case .address:
                    .just(target)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension QRCodeScannerAdapter {

    private func handleAccountPickerBridge(event: QRCodeScannerAccountPickerBridge.Event) {
        func dismiss(completion: (() -> Void)?) {
            router?.viewControllable
                .uiviewController
                .dismiss(
                    animated: true,
                    completion: completion
                )
        }
        switch event {
        case .finished:
            dismiss { [accountPickerBridge] in
                accountPickerBridge?
                    .selectedTargetSubject
                    .send(completion: .failure(.parserError(QRScannerAdapterError.noAccountSelected)))
            }
        case .didSelect(let account, let receiveAddress):
            dismiss { [accountPickerBridge] in
                accountPickerBridge?
                    .selectedTargetSubject
                    .send(.address(account, receiveAddress))
            }
        }
    }
}

extension CryptoTargetQRCodeParserTarget {
    init(target: QRCodeParserTarget) {
        switch target {
        case .address(_, let address):
            self = .address(address)
        case .bitpay(let address):
            self = .bitpay(address)
        }
    }
}

extension QRCodeParserTarget {
    init(account: CryptoAccount, target: CryptoTargetQRCodeParserTarget) {
        switch target {
        case .address(let address):
            self = .address(account, address)
        case .bitpay(let address):
            self = .bitpay(address)
        }
    }

    var account: CryptoAccount? {
        switch self {
        case .bitpay:
            nil
        case .address(let account, _):
            account
        }
    }
}
