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
    private var walletConnectTarget: EthereumSignMessageTarget {
        transactionTarget as! EthereumSignMessageTarget
    }

    private let keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>
    private let ethereumSigner: EthereumSignerAPI
    private let feeService: EthereumFeeServiceAPI

    init(
        ethereumSigner: EthereumSignerAPI = resolve(),
        keyPairProvider: AnyKeyPairProvider<EthereumKeyPair> = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve()
    ) {
        self.ethereumSigner = ethereumSigner
        self.feeService = feeService
        self.keyPairProvider = keyPairProvider
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
    }

    func assertInputsValid() {
        precondition(sourceAccount is CryptoNonCustodialAccount)
        precondition(sourceCryptoCurrency == .ethereum)
        precondition(transactionTarget is EthereumSignMessageTarget)
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
        let message = TransactionConfirmation.Model.Message(
            dAppName: walletConnectTarget.dAppName,
            message: walletConnectTarget.readableMessage
        )
        return .just(
            pendingTransaction.update(
                confirmations: [
                    .imageNotice(imageNotice),
                    .notice(notice),
                    .network(network),
                    .message(message)
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
        sourceAccount.receiveAddress
            .map { [walletConnectTarget] receiveAddress in
                guard receiveAddress.address.caseInsensitiveCompare(walletConnectTarget.account) == .orderedSame else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
                return pendingTransaction
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        didExecute = true
        return keyPairProvider
            .keyPair(with: secondPassword)
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
