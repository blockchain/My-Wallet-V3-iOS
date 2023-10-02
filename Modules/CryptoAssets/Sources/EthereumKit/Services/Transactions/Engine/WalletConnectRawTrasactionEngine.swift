// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class WalletConnectRawTrasactionEngine: TransactionEngine {

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    private var didExecute = false
    private var cancellables: Set<AnyCancellable> = []
    private var walletConnectTarget: EthereumRawTransactionTarget {
        transactionTarget as! EthereumRawTransactionTarget
    }

    private let feeService: EthereumFeeServiceAPI
    private let network: EVMNetwork
    private let sendingService: EthereumTransactionSendingServiceAPI

    init(
        network: EVMNetwork,
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        sendingService: EthereumTransactionSendingServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.currencyConversionService = currencyConversionService
        self.feeService = feeService
        self.network = network
        self.sendingService = sendingService
        self.walletCurrencyService = walletCurrencyService
    }

    func assertInputsValid() {
        precondition(sourceAccount is CryptoNonCustodialAccount)
        precondition(sourceCryptoCurrency == .ethereum)
        precondition(transactionTarget is EthereumRawTransactionTarget)
    }

    func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> AnyPublisher<PendingTransaction, Error> {
        let notice = TransactionConfirmations.Notice(
            value: String(
                format: LocalizationConstants.Transaction.Sign.dappRequestWarning,
                walletConnectTarget.dAppName
            )
        )
        let imageNotice = TransactionConfirmations.ImageNotice(
            imageURL: walletConnectTarget.dAppLogoURL,
            title: walletConnectTarget.dAppName,
            subtitle: walletConnectTarget.dAppAddress
        )
        let network = TransactionConfirmations.Network(
            network: AssetModel.ethereum.name
        )
        let message = TransactionConfirmations.RawTransaction(
            dAppName: walletConnectTarget.dAppName,
            rawTransaction: walletConnectTarget.rawTransaction.toHexString()
        )
        return .just(
            pendingTransaction.update(
                confirmations: [
                    imageNotice,
                    notice,
                    network,
                    message
                ]
            )
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        walletCurrencyService
            .displayCurrency
            .map { fiatCurrency -> PendingTransaction in
                .init(
                    amount: MoneyValue.create(minor: 1, currency: .crypto(.ethereum)),
                    available: .zero(currency: .ethereum),
                    feeAmount: .zero(currency: .ethereum),
                    feeForFullAvailable: .zero(currency: .ethereum),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular],
                        asset: .crypto(.ethereum)
                    ),
                    selectedFiatCurrency: fiatCurrency
                )
            }
            .asSingle()
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single
            .just(pendingTransaction.update(validationState: .canExecute))
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.just(pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        didExecute = true
        let encodedTransaction = EthereumTransactionEncoded(
            encodedTransaction: walletConnectTarget.rawTransaction
        )
        return sendingService
            .send(transaction: encodedTransaction, network: network.networkConfig)
            .map(\.transactionHash)
            .map { transactionHash -> TransactionResult in
                .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
            }
            .asSingle()
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    private lazy var rejectOnce: Void = walletConnectTarget.onTransactionRejected()
        .subscribe()
        .store(in: &self.cancellables)

    func stop(pendingTransaction: PendingTransaction) {
        if !didExecute {
            _ = rejectOnce
        }
    }
}
