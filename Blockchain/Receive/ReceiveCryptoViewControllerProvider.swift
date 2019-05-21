//
//  ReceiveCryptoViewControllerProvider.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit
import PlatformUIKit
import StellarKit

final class ReceiveCryptoTextViewModel: ReceiveCryptoTextViewModelProtocol {

    let copiedToClipboardText = LocalizationConstants.Receive.copiedToClipboard
    let enterYourSecondPasswordText = LocalizationConstants.Receive.enterYourSecondPassword
    let requestPaymentText = LocalizationConstants.Receive.requestPayment
    let tapToCopyThisAddress = LocalizationConstants.Receive.tapToCopyThisAddress

    var requestPaymentMessagePrefix: String {
        return String(format: LocalizationConstants.Receive.pleaseSendXto, cryptoCurrency.symbol)
    }

    var requestPaymentSubject: String {
        return String(format: LocalizationConstants.Receive.xPaymentRequest, cryptoCurrency.symbol)
    }

    var secondPasswordPrompt: String {
        return String(format: LocalizationConstants.Receive.secondPasswordPromptX, cryptoCurrency.symbol)
    }

    private let cryptoCurrency: CryptoCurrency

    init(cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
    }
}

final class ReceiveCryptoViewModelProvider {

    static let shared = ReceiveCryptoViewModelProvider(
        ethAccountRepo: ETHServiceProvider.shared.repository,
        ethQRMetadataFactory: ETHServiceProvider.shared.qrMetadataFactory,
        stellarAccountRepo: StellarWalletAccountRepository(with: WalletManager.shared.wallet),
        stellarQRMetadataFactory: StellarQRMetadataFactory()
    )

    private let ethAccountRepo: EthereumWalletAccountRepository
    private let ethQRMetadataFactory: EthereumQRMetadataFactory
    private let stellarAccountRepo: StellarWalletAccountRepository
    private let stellarQRMetadataFactory: StellarQRMetadataFactory

    init(
        ethAccountRepo: EthereumWalletAccountRepository,
        ethQRMetadataFactory: EthereumQRMetadataFactory,
        stellarAccountRepo: StellarWalletAccountRepository,
        stellarQRMetadataFactory: StellarQRMetadataFactory
    ) {
        self.ethAccountRepo = ethAccountRepo
        self.ethQRMetadataFactory = ethQRMetadataFactory
        self.stellarAccountRepo = stellarAccountRepo
        self.stellarQRMetadataFactory = stellarQRMetadataFactory
    }

    func provide(for cryptoCurrency: CryptoCurrency) -> ReceiveCryptoViewModelProtocol? {
        switch cryptoCurrency {
        case .bitcoin,
             .bitcoinCash:
            Logger.shared.warning("Not supported for \(cryptoCurrency)")
            return nil
        case .ethereum,
             .pax:
            return ReceiveCryptoViewModel<EthereumQRMetadata, EthereumWalletAccount>(
                cryptoCurrency: cryptoCurrency,
                textViewModel: ReceiveCryptoTextViewModel(
                    cryptoCurrency: cryptoCurrency
                ),
                walletInitializer: AnyWalletAccountInitializer(
                    initializer: ethAccountRepo
                ),
                factory: AnyCryptoAssetQRMetadataFactory(
                    factory: ethQRMetadataFactory
                )
            )
        case .stellar:
            return ReceiveCryptoViewModel<StellarQRMetadata, StellarWalletAccount>(
                cryptoCurrency: cryptoCurrency,
                textViewModel: ReceiveCryptoTextViewModel(
                    cryptoCurrency: cryptoCurrency
                ),
                walletInitializer: AnyWalletAccountInitializer(
                    initializer: stellarAccountRepo
                ),
                factory: AnyCryptoAssetQRMetadataFactory(
                    factory: stellarQRMetadataFactory
                )
            )
        }
    }
}

// MARK: Objective-C Compatibility

extension ReceiveCryptoViewController {
    @objc class func make(for legacyAssetType: LegacyAssetType) -> ReceiveCryptoViewController {
        let receiveViewController = ReceiveCryptoViewController.makeFromStoryboard()
        let crypto = CryptoCurrency(from: legacyAssetType)
        receiveViewController.viewModel = ReceiveCryptoViewModelProvider.shared.provide(for: crypto)
        return receiveViewController
    }

    @objc func legacyAssetType() -> LegacyAssetType {
        // Can't return an optional LegacyAssetType in Objective-C
        return viewModel?.cryptoCurrency.assetType.legacy ?? LegacyAssetType.bitcoin
    }
}

extension CryptoCurrency {
    init(from legacyAssetType: LegacyAssetType) {
        switch legacyAssetType {
        case .bitcoin:
            self = CryptoCurrency.bitcoin
        case .bitcoinCash:
            self = CryptoCurrency.bitcoinCash
        case .ether:
            self = CryptoCurrency.ethereum
        case .stellar:
            self = CryptoCurrency.stellar
        case .pax:
            self = CryptoCurrency.pax
        }
    }
}
