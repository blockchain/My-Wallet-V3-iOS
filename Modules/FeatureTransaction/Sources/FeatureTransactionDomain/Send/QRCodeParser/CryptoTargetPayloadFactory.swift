// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift

public enum CryptoTargetQRCodeParserTarget {
    case address(CryptoReceiveAddress)
    case bitpay(String)
}

public protocol CryptoTargetPayloadFactoryAPI {
    func create(
        fromString string: String?,
        asset: CryptoCurrency
    ) -> AnyPublisher<CryptoTargetQRCodeParserTarget, CryptoTargetPayloadError>
}

public enum CryptoTargetPayloadError: Error {
    case invalidStringData
    case bitPay(Error)
}

final class CryptoTargetPayloadFactory: CryptoTargetPayloadFactoryAPI {

    // MARK: - Private Properties

    private let receiveAddressService: ExternalAssetAddressServiceAPI

    // MARK: - Init

    init(receiveAddressService: ExternalAssetAddressServiceAPI = resolve()) {
        self.receiveAddressService = receiveAddressService
    }

    // MARK: - CryptoTargetPayloadFactoryAPI

    func create(
        fromString string: String?,
        asset: CryptoCurrency
    ) -> AnyPublisher<CryptoTargetQRCodeParserTarget, CryptoTargetPayloadError> {
        guard let string else {
            return .failure(CryptoTargetPayloadError.invalidStringData)
        }
        let metadata = makeCryptoQRMetaData(
            fromString: string,
            asset: asset
        )
        if BitPayInvoiceTarget.isBitPay(string),
           BitPayInvoiceTarget.isSupportedAsset(asset)
        {
            return .just(.bitpay(string))
        } else {
            return metadata
        }
    }

    // MARK: - Private Functions

    private func makeCryptoQRMetaData(
        fromString string: String,
        asset: CryptoCurrency
    ) -> AnyPublisher<CryptoTargetQRCodeParserTarget, CryptoTargetPayloadError> {
        receiveAddressService
            .makeExternalAssetAddress(
                asset: asset,
                address: string,
                label: string,
                onTxCompleted: { _ in AnyPublisher.just(()) }
            )
            .map(CryptoTargetQRCodeParserTarget.address)
            .replaceError(with: CryptoTargetPayloadError.invalidStringData)
            .publisher
            .eraseToAnyPublisher()
    }
}
