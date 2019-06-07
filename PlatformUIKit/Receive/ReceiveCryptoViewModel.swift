//
//  ReceiveCryptoViewModel.swift
//  PlatformUIKit
//
//  Created by Chris Arriola on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol ReceiveCryptoTextViewModelProtocol {
    var copiedToClipboardText: String { get }
    var enterYourSecondPasswordText: String { get }
    var requestPaymentText: String { get }
    var requestPaymentMessagePrefix: String { get }
    var requestPaymentSubject: String { get }
    var tapToCopyThisAddress: String { get }
    var secondPasswordPrompt: String { get }
}

public protocol ReceiveCryptoViewModelProtocol {
    var cryptoCurrency: CryptoCurrency { get }
    var textViewModel: ReceiveCryptoTextViewModelProtocol { get }
    func initializeWalletAccount() -> Maybe<WalletAccount>
    func qrCode(from walletAccount: WalletAccount) -> QRCode?
}

public final class ReceiveCryptoViewModel<Metadata: CryptoAssetQRMetadata, Account: WalletAccount>: ReceiveCryptoViewModelProtocol {

    public let cryptoCurrency: CryptoCurrency
    public let textViewModel: ReceiveCryptoTextViewModelProtocol

    private let walletInitializer: AnyWalletAccountInitializer<Account>
    private let factory: AnyCryptoAssetQRMetadataFactory<Metadata, Account>

    public init(
        cryptoCurrency: CryptoCurrency,
        textViewModel: ReceiveCryptoTextViewModelProtocol,
        walletInitializer: AnyWalletAccountInitializer<Account>,
        factory: AnyCryptoAssetQRMetadataFactory<Metadata, Account>
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.textViewModel = textViewModel
        self.walletInitializer = walletInitializer
        self.factory = factory
    }

    public func initializeWalletAccount() -> Maybe<WalletAccount> {
        return walletInitializer.initializeMetadataMaybe()
            .map { $0 as WalletAccount }
    }

    public func qrCode(from walletAccount: WalletAccount) -> QRCode? {
        guard let account = walletAccount as? Account else {
            // TODO: Log
            return nil
        }
        guard let qrMetadata = factory.create(from: account) else {
            // TODO: Log
            return nil
        }
        return QRCode(metadata: qrMetadata)
    }
}
