// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

extension CoincoreAPI {

    public func createTransactionProcessor(
        with account: BlockchainAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        switch account {
        case let account as CryptoNonCustodialAccount:
            return createOnChainProcessor(
                with: account,
                target: target,
                action: action
            )
        case let account as CryptoInterestAccount:
            return createInterestWithdrawTradingProcessor(
                with: account,
                target: target,
                action: action
            )
        case let account as CryptoTradingAccount:
            return createTradingProcessor(
                with: account,
                target: target,
                action: action
            )
        case let account as LinkedBankAccount where action == .deposit:
            return createFiatDepositProcessor(
                with: account,
                target: target
            )
        case is FiatAccount where action == .buy:
            return createBuyProcessor(
                with: account,
                destination: target
            )
        case let account as FiatAccount where action == .withdraw:
            return createFiatWithdrawalProcessor(
                with: account,
                target: target
            )
        case let account as CryptoDelegatedCustodyAccount:
            return createDelegatedCustodyProcessor(
                with: account,
                target: target,
                action: action
            )
        default:
            impossible()
        }
    }

    private func createOnChainProcessor(
        with account: CryptoNonCustodialAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        let factory = account.createTransactionEngine() as! OnChainTransactionEngineFactory
        let interestOnChainFactory: InterestOnChainTransactionEngineFactoryAPI = resolve()
        switch (target, action) {
        case (is CryptoInterestAccount, .interestTransfer):
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: interestOnChainFactory
                        .build(
                            action: .interestTransfer,
                            onChainEngine: factory.build()
                        )
                )
            )
        case (is CryptoStakingAccount, .stakingDeposit):
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: interestOnChainFactory
                        .build(
                            action: .stakingDeposit,
                            onChainEngine: factory.build()
                        )
                )
            )
        case (is WalletConnectTarget, _):
            let walletConnectEngineFactory: WalletConnectEngineFactoryAPI = resolve()
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: walletConnectEngineFactory.build(
                        target: target
                    )
                )
            )
        case (is BitPayInvoiceTarget, .send):
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: BitPayTransactionEngine(
                        onChainEngine: factory.build()
                    )
                )
            )
        case (is CryptoAccount, .swap):
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: OnChainSwapTransactionEngine(
                        onChainEngine: factory.build()
                    )
                )
            )
        case (let target as CryptoReceiveAddress, .send):
            // `Target` must be a `CryptoReceiveAddress` or CryptoAccount.
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: factory.build()
                )
            )

        case (let target as CryptoAccount, .send):
            // `Target` must be a `CryptoReceiveAddress` or CryptoAccount.
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: factory.build()
                )
            )
        case (_, .sell):
            return .just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: NonCustodialSellTransactionEngine(
                        onChainEngine: factory.build()
                    )
                )
            )
        default:
            unimplemented()
        }
    }

    private func createDelegatedCustodyProcessor(
        with account: CryptoDelegatedCustodyAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        switch action {
        case .send:
            return createDelegatedCustodyProcessorSend(with: account, target: target)
        case .buy,
                .deposit,
                .interestTransfer,
                .interestWithdraw,
                .stakingDeposit,
                .receive,
                .sell,
                .sign,
                .swap,
                .viewActivity,
                .withdraw:
            unimplemented()
        }
    }

    private func createTradingProcessor(
        with account: CryptoTradingAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        switch action {
        case .swap:
            return createTradingProcessorSwap(with: account, target: target)
        case .send:
            return createTradingProcessorSend(with: account, target: target)
        case .buy:
            unimplemented("This should not be needed as the Buy engine should process the transaction")
        case .sell:
            return createTradingProcessorSell(with: account, target: target)
        case .interestTransfer:
            return createInterestTransferTradingProcessor(with: account, target: target)
        case .stakingDeposit:
            return createStakingDepositTradingProcessor(with: account, target: target)
        case .deposit,
             .receive,
             .sign,
             .viewActivity,
             .withdraw,
             .interestWithdraw:
            unimplemented()
        }
    }

    private func createBuyProcessor(
        with source: BlockchainAccount,
        destination: TransactionTarget
    ) -> Single<TransactionProcessor> {
        .just(
            TransactionProcessor(
                sourceAccount: source,
                transactionTarget: destination,
                engine: BuyTransactionEngine()
            )
        )
    }

    private func createFiatWithdrawalProcessor(
        with account: FiatAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        Single.just(
            TransactionProcessor(
                sourceAccount: account,
                transactionTarget: target,
                engine: FiatWithdrawalTransactionEngine()
            )
        )
    }

    private func createFiatDepositProcessor(
        with account: LinkedBankAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        Single.just(
            TransactionProcessor(
                sourceAccount: account,
                transactionTarget: target,
                engine: FiatDepositTransactionEngine()
            )
        )
    }

    private func createTradingProcessorSwap(
        with account: CryptoTradingAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        Single.just(
            TransactionProcessor(
                sourceAccount: account,
                transactionTarget: target as! CryptoTradingAccount,
                engine: TradingToTradingSwapTransactionEngine()
            )
        )
    }

    private func createInterestTransferTradingProcessor(
        with account: CryptoTradingAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        guard target is CryptoInterestAccount else {
            impossible()
        }
        let factory: InterestTradingTransactionEngineFactoryAPI = resolve()
        return .just(
            .init(
                sourceAccount: account,
                transactionTarget: target,
                engine: factory
                    .build(
                        action: .interestTransfer
                    )
            )
        )
    }

    private func createStakingDepositTradingProcessor(
        with account: CryptoTradingAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        guard target is CryptoStakingAccount else {
            impossible()
        }
        let factory: InterestTradingTransactionEngineFactoryAPI = resolve()
        return .just(
            .init(
                sourceAccount: account,
                transactionTarget: target,
                engine: factory
                    .build(
                        action: .stakingDeposit
                    )
            )
        )
    }

    private func createInterestWithdrawTradingProcessor(
        with account: CryptoInterestAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        let tradingFactory: InterestTradingTransactionEngineFactoryAPI = resolve()
        let onChainFactory: InterestOnChainTransactionEngineFactoryAPI = resolve()
        switch target {
        case is CryptoTradingAccount:
            return Single.just(
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: target,
                    engine: tradingFactory
                        .build(
                            action: action
                        )
                )
            )
        case let target as CryptoNonCustodialAccount:
            let factory = target.createTransactionEngine() as! OnChainTransactionEngineFactory
            return target
                .receiveAddress
                .map { receiveAddress in
                    TransactionProcessor(
                        sourceAccount: account,
                        transactionTarget: receiveAddress,
                        engine: onChainFactory
                            .build(
                                action: action,
                                onChainEngine: factory.build()
                            )
                    )
                }
                .asSingle()
        default:
            unimplemented()
        }
    }

    private func createDelegatedCustodyProcessorSend(
        with account: CryptoDelegatedCustodyAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        receiveAddress(from: target)
            .map { receiveAddress in
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: receiveAddress,
                    engine: DelegatedSelfCustodyTransactionEngine(
                        currencyConversionService: resolve(),
                        transactionService: resolve(),
                        walletCurrencyService: resolve()
                    )
                )
            }
            .asSingle()
    }

    private func createTradingProcessorSend(
        with account: CryptoTradingAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        receiveAddress(from: target)
            .map { receiveAddress in
                TransactionProcessor(
                    sourceAccount: account,
                    transactionTarget: receiveAddress,
                    engine: TradingToOnChainTransactionEngine()
                )
            }
            .asSingle()
    }

    private func createTradingProcessorSell(
        with account: CryptoAccount,
        target: TransactionTarget
    ) -> Single<TransactionProcessor> {
        .just(
            TransactionProcessor(
                sourceAccount: account,
                transactionTarget: target as! FiatAccount,
                engine: TradingSellTransactionEngine()
            )
        )
    }

    private func receiveAddress(
        from target: TransactionTarget
    ) -> AnyPublisher<ReceiveAddress, Error> {
        switch target {
        case let target as ReceiveAddress:
            return .just(target)
        case let target as BlockchainAccount:
            return target.receiveAddress
        default:
            impossible()
        }
    }
}
