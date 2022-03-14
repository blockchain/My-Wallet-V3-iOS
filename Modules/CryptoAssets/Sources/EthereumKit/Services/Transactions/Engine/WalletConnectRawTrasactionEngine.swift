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

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        walletCurrencyService
            .displayCurrencyPublisher
            .map { fiatCurrency -> MoneyValuePair in
                MoneyValuePair(
                    base: .one(currency: .crypto(.ethereum)),
                    quote: .one(currency: fiatCurrency)
                )
            }
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    let requireSecondPassword: Bool = false

    private var didExecute = false
    private var cancellables: Set<AnyCancellable> = []
    private var walletConnectTarget: EthereumRawTransactionTarget {
        transactionTarget as! EthereumRawTransactionTarget
    }

    private let sendingService: EthereumTransactionSendingServiceAPI
    private let feeService: EthereumFeeServiceAPI

    init(
        sendingService: EthereumTransactionSendingServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve()
    ) {
        self.currencyConversionService = currencyConversionService
        self.feeService = feeService
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

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        let notice = TransactionConfirmation.Model.Notice(
            value: String(
                format: LocalizationConstants.Transaction.Sign.dappRequestWarning,
                walletConnectTarget.dAppName
            )
        )
        let imageNotice = TransactionConfirmation.Model.ImageNotice(
            imageURL: walletConnectTarget.dAppLogoURL,
            title: walletConnectTarget.dAppName,
            subtitle: walletConnectTarget.dAppAddress
        )
        let network = TransactionConfirmation.Model.Network(
            network: AssetModel.ethereum.name
        )
        let message = TransactionConfirmation.Model.RawTransaction(
            dAppName: walletConnectTarget.dAppName,
            rawTransaction: walletConnectTarget.rawTransaction.toHexString()
        )
        return .just(
            pendingTransaction.update(
                confirmations: [
                    .imageNotice(imageNotice),
                    .notice(notice),
                    .network(network),
                    .rawTransaction(message)
                ]
            )
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        walletCurrencyService
            .displayCurrency
            .map { fiatCurrency -> PendingTransaction in
                .init(
                    amount: MoneyValue(amount: 1, currency: .crypto(.ethereum)),
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

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        didExecute = true
        let encodedTransaction = EthereumTransactionEncoded(
            encodedTransaction: walletConnectTarget.rawTransaction
        )
        return sendingService
            .send(transaction: encodedTransaction)
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
