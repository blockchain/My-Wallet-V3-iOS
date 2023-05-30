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

final class WalletConnectSignMessageEngine: TransactionEngine {

    let network: EVMNetwork
    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var askForRefreshConfirmation: AskForRefreshConfirmation!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        walletCurrencyService
            .displayCurrencyPublisher
            .map { [network] fiatCurrency -> MoneyValuePair in
                MoneyValuePair(
                    base: .one(currency: .crypto(network.nativeAsset)),
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

    private var didExecute = false
    private var cancellables: Set<AnyCancellable> = []
    private var walletConnectTarget: EthereumSignMessageTarget {
        transactionTarget as! EthereumSignMessageTarget
    }

    private let keyPairProvider: EthereumKeyPairProvider
    private let ethereumSigner: EthereumSignerAPI
    private let feeService: EthereumFeeServiceAPI

    init(
        network: EVMNetwork,
        ethereumSigner: EthereumSignerAPI = resolve(),
        keyPairProvider: EthereumKeyPairProvider = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve()
    ) {
        self.network = network
        self.ethereumSigner = ethereumSigner
        self.feeService = feeService
        self.keyPairProvider = keyPairProvider
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
    }

    func assertInputsValid() {
        precondition(sourceAccount is EVMCryptoAccount)
        precondition(transactionTarget is EthereumSignMessageTarget)
        precondition(
            isCurrencyTypeValid(sourceCryptoCurrency.currencyType),
            "Invalid source asset '\(sourceCryptoCurrency.code)'."
        )
    }

    private func isCurrencyTypeValid(_ value: CurrencyType) -> Bool {
        value == .crypto(network.nativeAsset)
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
            network: walletConnectTarget.network.networkConfig.name
        )
        let message = TransactionConfirmations.Message(
            dAppName: walletConnectTarget.dAppName,
            message: walletConnectTarget.readableMessage
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
            .map { [network] fiatCurrency -> PendingTransaction in
                .init(
                    amount: MoneyValue.create(minor: 1, currency: .crypto(network.nativeAsset)),
                    available: .zero(currency: network.nativeAsset),
                    feeAmount: .zero(currency: network.nativeAsset),
                    feeForFullAvailable: .zero(currency: network.nativeAsset),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular],
                        asset: .crypto(network.nativeAsset)
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
        sourceAccount.receiveAddress
            .asSingle()
            .map { [walletConnectTarget] receiveAddress in
                guard receiveAddress.address.caseInsensitiveCompare(walletConnectTarget.account) == .orderedSame else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
                return pendingTransaction
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction) -> Single<TransactionResult> {
        didExecute = true
        return keyPairProvider
            .keyPair
            .asSingle()
            .flatMap { [ethereumSigner, walletConnectTarget] ethereumKeyPair -> Single<Data> in
                switch walletConnectTarget.message {
                case .data(let data):
                    return ethereumSigner
                        .sign(messageData: data, keyPair: ethereumKeyPair)
                        .single
                case .typedData(let typedData):
                    return ethereumSigner
                        .signTypedData(messageJson: typedData, keyPair: ethereumKeyPair)
                        .single
                }
            }
            .map { personalSigned -> TransactionResult in
                .signed(rawTx: personalSigned.hexString.withHex)
            }
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
