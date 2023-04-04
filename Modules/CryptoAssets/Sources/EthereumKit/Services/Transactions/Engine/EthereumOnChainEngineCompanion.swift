// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

public protocol EthereumOnChainEngineCompanionAPI: AnyObject {
    /**
     Ethereum Destination addresses.

     - Returns: Single that emits a tuple with the destination address (`destination`) and the reference address
     (`referenceAddress`) for the given `TransactionTarget`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    func destinationAddresses(
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<(destination: EthereumAddress, referenceAddress: EthereumAddress?)>

    /// The `TransactionTarget` receive address.
    func receiveAddress(
        transactionTarget: TransactionTarget
    ) -> Single<ReceiveAddress>

    /// The `TransactionTarget` address reference.
    /// If we are not sending directly to a HotWalletTransactionTarget, then this will emit 'nil'.
    func addressReference(
        transactionTarget: TransactionTarget
    ) -> Single<ReceiveAddress?>

    /// Returns any extra gas limit that we may need to add to the base gas limit.
    /// Used when we are appending or adding extra data to the transaction.
    func extraGasLimit(
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<BigUInt>

    /// Returns Ethereum CryptoValue of the maximum fee that the user may pay.
    func absoluteFee(
        feeLevel: FeeLevel,
        fees: EthereumTransactionFee,
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI,
        isContract: Bool
    ) -> Single<CryptoValue>
}

final class EthereumOnChainEngineCompanion: EthereumOnChainEngineCompanionAPI {

    // MARK: - Types

    private enum Constants {
        static let extraGasLimitForEthereumMemo = BigUInt(600)
    }

    // MARK: - Private Properties

    private let hotWalletAddressService: HotWalletAddressServiceAPI

    // MARK: - Init

    init(hotWalletAddressService: HotWalletAddressServiceAPI) {
        self.hotWalletAddressService = hotWalletAddressService
    }

    // MARK: - Methods

    /// Returns Ethereum CryptoValue of the maximum fee that the user may pay.
    func absoluteFee(
        feeLevel: FeeLevel,
        fees: EthereumTransactionFee,
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI,
        isContract: Bool
    ) -> Single<CryptoValue> {
        extraGasLimit(
            transactionTarget: transactionTarget,
            cryptoCurrency: cryptoCurrency,
            receiveAddressFactory: receiveAddressFactory
        )
        .map { extraGasLimit -> CryptoValue in
            fees.absoluteFee(
                with: feeLevel.ethereumFeeLevel,
                extraGasLimit: extraGasLimit,
                isContract: isContract
            )
        }
    }

    func destinationAddresses(
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<(destination: EthereumAddress, referenceAddress: EthereumAddress?)> {
        let receiveAddresses: Single<(destination: ReceiveAddress, referenceAddress: ReceiveAddress?)>
        switch transactionTarget {
        case let blockchainAccount as BlockchainAccount:
            receiveAddresses = createDestinationAddress(
                blockchainAccount: blockchainAccount,
                transactionTarget: transactionTarget,
                cryptoCurrency: cryptoCurrency,
                receiveAddressFactory: receiveAddressFactory
            )
        default:
            receiveAddresses = Single
                .zip(
                    receiveAddress(transactionTarget: transactionTarget),
                    addressReference(transactionTarget: transactionTarget)
                )
                .map { (destination: $0.0, referenceAddress: $0.1) }
        }

        return receiveAddresses
            .map { addresses -> (destination: EthereumAddress, referenceAddress: EthereumAddress?) in
                let destination = try EthereumAddress(string: addresses.destination.address, network: .ethereum)
                guard let referenceAddress = addresses.referenceAddress else {
                    return (destination, nil)
                }
                return try (destination, EthereumAddress(string: referenceAddress.address, network: .ethereum))
            }
    }

    /// The current transactionTarget receive address.
    func receiveAddress(
        transactionTarget: TransactionTarget
    ) -> Single<ReceiveAddress> {
        switch transactionTarget {
        case let target as ReceiveAddress:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress.asSingle()
        case let target as HotWalletTransactionTarget:
            return .just(target.hotWalletAddress)
        default:
            fatalError(
                "Impossible State \(type(of: self)): transactionTarget is \(type(of: transactionTarget))"
            )
        }
    }

    /// The current transactionTarget address reference.
    /// If we are not sending directly to a HotWalletTransactionTarget, then this will emit 'nil'.
    func addressReference(
        transactionTarget: TransactionTarget
    ) -> Single<ReceiveAddress?> {
        switch transactionTarget {
        case let target as HotWalletTransactionTarget:
            return .just(target.realAddress)
        default:
            return .just(nil)
        }
    }

    /// Returns any extra gas limit that we may need to add to the base gas limit.
    /// Used when we are appending or adding extra data to the transaction.
    func extraGasLimit(
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<BigUInt> {
        destinationAddresses(
            transactionTarget: transactionTarget,
            cryptoCurrency: cryptoCurrency,
            receiveAddressFactory: receiveAddressFactory
        )
        .map(\.referenceAddress)
        .map { referenceAddress -> BigUInt in
            referenceAddress != nil ? Constants.extraGasLimitForEthereumMemo : 0
        }
    }

    // MARK: - Private Methods

    /**
     Hot Wallet Receive Address.

     - Returns: Single that emits the hot wallet receive address for the given `product` and for the current `sourceCryptoCurrency`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private func hotWalletReceiveAddress(
        for product: HotWalletProduct,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<CryptoReceiveAddress?> {
        hotWalletAddressService
            .hotWalletAddress(for: cryptoCurrency, product: product)
            .asSingle()
            .flatMap { hotWalletAddress -> Single<CryptoReceiveAddress?> in
                guard let hotWalletAddress else {
                    return .just(nil)
                }
                return receiveAddressFactory.makeExternalAssetAddress(
                    asset: cryptoCurrency,
                    address: hotWalletAddress,
                    label: hotWalletAddress,
                    onTxCompleted: { _ in AnyPublisher.just(()) }
                )
                .single
                .optional()
            }
    }

    /**
     Destination addresses for a BlockchainAccount.
     If we are sending to a Custodial Account (Trading, Exchange, Interest), we must generate the 'addressReference' ourselves.

     - Returns: Single that emits a tuple with the destination address (`destination`) and the reference address
     (`referenceAddress`) for the given `BlockchainAccount`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private func createDestinationAddress(
        blockchainAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        cryptoCurrency: CryptoCurrency,
        receiveAddressFactory: ExternalAssetAddressServiceAPI
    ) -> Single<(destination: ReceiveAddress, referenceAddress: ReceiveAddress?)> {
        let product: HotWalletProduct
        switch blockchainAccount {
        case is CryptoTradingAccount:
            product = .trading
        case is InterestAccount:
            product = .rewards
        case is ExchangeAccount:
            product = .exchange
        default:
            return Single
                .zip(
                    receiveAddress(transactionTarget: transactionTarget),
                    addressReference(transactionTarget: transactionTarget)
                )
                .map { receiveAddress, addressReference in
                    (destination: receiveAddress, referenceAddress: addressReference)
                }
        }
        let hotWalletAddress = hotWalletReceiveAddress(
            for: product,
            cryptoCurrency: cryptoCurrency,
            receiveAddressFactory: receiveAddressFactory
        )
        return Single
            .zip(
                blockchainAccount.receiveAddress.asSingle(),
                hotWalletAddress
            )
            .map { receiveAddress, hotWalletAddress in
                guard let hotWalletAddress else {
                    return (destination: receiveAddress, referenceAddress: nil)
                }
                return (destination: hotWalletAddress, referenceAddress: receiveAddress)
            }
    }
}
