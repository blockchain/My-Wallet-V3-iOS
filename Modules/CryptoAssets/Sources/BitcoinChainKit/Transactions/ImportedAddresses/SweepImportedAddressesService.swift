// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Coincore
import Combine
import Extensions
import FeatureTransactionDomain
import RxSwift
import ToolKit

public protocol SweepImportedAddressesServiceAPI {
    var importedAddresses: AnyPublisher<[BitcoinChainCryptoAccount], Error> { get }

    /// Gathers any imported addresses that need sweeping
    func prepare(force: Bool) -> AnyPublisher<[BitcoinChainCryptoAccount], Error>

    /// Performs sweep on any imported addresses
    func performSweep() -> AnyPublisher<[TxPairResult], Error>
}

final class SweepImportedAddressesService: SweepImportedAddressesServiceAPI {

    var importedAddresses: AnyPublisher<[BitcoinChainCryptoAccount], Error> {
        importedAddressSubject
            .eraseToAnyPublisher()
    }

    let importedAddressesProvider: (_ sweptBalances: [String]) -> AnyPublisher<[BitcoinChainCryptoAccount], Error>
    let defaultAccount: (BitcoinChainCoin) -> AnyPublisher<BitcoinChainCryptoAccount, Error>

    let btcAddressProvider: BitcoinChainReceiveAddressProviderAPI
    var bchAddressProvider: BitcoinChainReceiveAddressProviderAPI
    let btcFetchMultiAddrFor: FetchMultiAddressFor
    let bchFetchMultiAddrFor: FetchMultiAddressFor

    let sweptBalancesRepository: SweepImportedAddressesRepositoryAPI

    let doPerformSweep: DoPerformSweep

    private var bag: Set<AnyCancellable> = []

    private let importedAddressSubject = CurrentValueSubject<[BitcoinChainCryptoAccount], Error>([])

    init(
        sweptBalancesRepository: SweepImportedAddressesRepositoryAPI,
        btcAddressProvider: BitcoinChainReceiveAddressProviderAPI,
        bchAddressProvider: BitcoinChainReceiveAddressProviderAPI,
        btcFetchMultiAddrFor: @escaping FetchMultiAddressFor,
        bchFetchMultiAddrFor: @escaping FetchMultiAddressFor,
        importedAddresses: @escaping ([String]) -> AnyPublisher<[BitcoinChainCryptoAccount], Error>,
        defaultAccount: @escaping (BitcoinChainCoin) -> AnyPublisher<BitcoinChainCryptoAccount, Error>,
        doPerformSweep: @escaping DoPerformSweep
    ) {
        self.sweptBalancesRepository = sweptBalancesRepository
        self.btcAddressProvider = btcAddressProvider
        self.bchAddressProvider = bchAddressProvider
        self.btcFetchMultiAddrFor = btcFetchMultiAddrFor
        self.bchFetchMultiAddrFor = bchFetchMultiAddrFor
        self.importedAddressesProvider = importedAddresses
        self.defaultAccount = defaultAccount
        self.doPerformSweep = doPerformSweep

        sweptBalancesRepository.prepare()
    }

    func prepare(force: Bool) -> AnyPublisher<[BitcoinChainCryptoAccount], Error> {
        if importedAddressSubject.value.isEmpty || force {
            return importedAddressesProvider(sweptBalancesRepository.sweptBalances)
                .handleEvents(
                    receiveOutput: { [importedAddressSubject] pairs in
                        importedAddressSubject.send(pairs)
                    }
                )
                .eraseToAnyPublisher()
        } else {
            return importedAddressSubject
                .eraseToAnyPublisher()
        }
    }

    func performSweep() -> AnyPublisher<[TxPairResult], Error> {
        let txFactory: (BitcoinChainCryptoAccount) -> OnChainTransactionEngine = { account in
            let factory = account.createTransactionEngine() as! OnChainTransactionEngineFactory
            return factory.build()
        }

        return preparePairs()
            .flatMap { [weak self, doPerformSweep] pairs -> AnyPublisher<[TxPairResult], Never> in
                pairs
                    .publisher
                    .flatMap(maxPublishers: .max(1)) { pair -> AnyPublisher<TxPairResult, Never> in
                        doPerformSweep(pair.importedAddress, pair.target, txFactory)
                            .handleEvents(receiveOutput: { result in
                                guard let self, case .success = result.result else {
                                    return
                                }
                                self.sweptBalancesRepository.update(result: result)
                            })
                            .eraseToAnyPublisher()
                    }
                    .scan([TxPairResult]()) { prev, result in
                        prev + [result]
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveCompletion: { [sweptBalancesRepository] _ in
                sweptBalancesRepository.setLastSweptAttempt()
            })
            .eraseToAnyPublisher()
    }

    /// 1. get imported addresses
    /// 2. get default accounts for btc / bch
    /// 3. retrieve the latest receiveIndex for default btc / bch accounts
    /// 4. calculate the next `n` receive addresses for btc / bch where `n` the number of imported addreses
    /// 5. create pairs of source and target to be used in sweep
    func preparePairs() -> AnyPublisher<[TxPair], Error> {
        importedAddressSubject
            .zip(defaultAccount(.bitcoin), defaultAccount(.bitcoinCash))
            .flatMap { [btcFetchMultiAddrFor, bchFetchMultiAddrFor] imported, defaultBTCAccount, defaultBCHAccount -> AnyPublisher<PairsContext, Error> in
                Publishers.Zip(
                    getLatestReceiveIndexFor(xpub: defaultBTCAccount.xPub, using: btcFetchMultiAddrFor),
                    getLatestReceiveIndexFor(xpub: defaultBCHAccount.xPub, using: bchFetchMultiAddrFor)
                )
                .map { value -> PairsContext in
                    PairsContext(
                        btcReceiveIndex: value.0,
                        bchReceiveIndex: value.1,
                        imported: imported,
                        btcDefaultAccount: defaultBTCAccount,
                        bchDefaultAccount: defaultBCHAccount
                    )
                }
                .eraseToAnyPublisher()
            }
            .flatMap { [btcAddressProvider, bchAddressProvider] context -> AnyPublisher<[TxPair], Error> in
                let btcTxPairs = btcTxPairs(context: context, btcAddressProvider: btcAddressProvider)
                let bchTxPairs = bchTxPairs(context: context, bchAddressProvider: bchAddressProvider)
                return btcTxPairs
                    .zip(bchTxPairs)
                    .map { btcPairs, bchPairs -> [TxPair] in
                       btcPairs + bchPairs
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Sweep Method

typealias DoPerformSweep = (
    _ account: BitcoinChainCryptoAccount,
    _ target: CryptoReceiveAddress,
    _ txFactory: @escaping (BitcoinChainCryptoAccount) -> OnChainTransactionEngine
) -> AnyPublisher<TxPairResult, Never>

/// Performs a send transaction from account to target
/// - Parameters:
///   - account: An account to be used to send funds
///   - target: An target to be used to receive funds
/// - Returns: `AnyPublisher<Bool, Error>`
func doPerformSweep(
    on account: BitcoinChainCryptoAccount,
    target: CryptoReceiveAddress,
    txFactory: @escaping (BitcoinChainCryptoAccount) -> OnChainTransactionEngine
) -> AnyPublisher<TxPairResult, Never> {
    let txEngine = txFactory(account)

    txEngine.start(
        sourceAccount: account,
        transactionTarget: target,
        askForRefreshConfirmation: { _ in .empty() }
    )

    let sweepResult: Single<TxPairResult> = txEngine.initializeTransaction()
        .flatMap { pTx -> Single<PendingTransaction> in
            // pass in zero to calculate the max available balance
            txEngine.update(amount: .zero(currency: account.asset), pendingTransaction: pTx)
        }
        .flatMap { pTx -> Single<PendingTransaction> in
            txEngine.update(amount: pTx.available, pendingTransaction: pTx)
        }
        .flatMap { pTx -> Single<PendingTransaction> in
            txEngine.doValidateAll(pendingTransaction: pTx)
        }
        .flatMap { pTx -> Single<PendingTransaction> in
            txEngine.execute(pendingTransaction: pTx)
                .flatMap { result -> Single<PendingTransaction> in
                    txEngine.doPostExecute(transactionResult: result)
                        .map { _ in pTx }
                        .asSingle()
                }
        }
        .map { _ in
            TxPairResult(accountIdentifier: account.identifier, result: .success(.noValue))
        }
        .catch { error -> Single<TxPairResult> in
            .just(TxPairResult(accountIdentifier: account.identifier, result: .failure(error)))
        }

    return sweepResult
        .asPublisher()
        .catch { error -> TxPairResult in
            TxPairResult(accountIdentifier: account.identifier, result: .failure(error))
        }
        .eraseToAnyPublisher()
}

// MARK: - Account Providers

/// Provides any imported addresses that can be swept by determining the max avaiable balance (fee included)
/// 1. Fetch all imported "accounts"
/// 2. Fetch balance for each account
/// 3. Pick the default account & get the receive address
/// 4. Determine if imported account balance is sendable, by calculating the fee for a transaction
/// Skips any identifier that was recently swept
func importedAddressesProvider(
    coincore: CoincoreAPI,
    btcCandidateProvider: TransactionCandidateProviderAPI,
    bchCandidateProvider: TransactionCandidateProviderAPI,
    dispatchQueue: DispatchQueue,
    defaultAccountProvider: @escaping (BitcoinChainCoin) -> AnyPublisher<BitcoinChainCryptoAccount, Error>
) -> ([String]) -> AnyPublisher<[BitcoinChainCryptoAccount], Error> {
    { sweptBalances in
        coincore.accounts(filter: .nonCustodialImported) { account in
            guard let account = account as? BitcoinChainCryptoAccount else {
                return false
            }
            return account.isImported
        }
        .map { accounts in
            accounts
                .compactMap { $0 as? BitcoinChainCryptoAccount }
                .filter { account in
                    !sweptBalances.contains(where: { account.identifier == $0 })
                }
        }
        .receive(on: dispatchQueue)
        .flatMap { accounts -> AnyPublisher<[(BitcoinChainCryptoAccount, MoneyValue)], Never> in
            accounts.map { account in
                account.balance
                    .replaceError(with: MoneyValue.zero(currency: account.asset))
                    .map { (account, $0) }
                    .eraseToAnyPublisher()
            }
            .combineLatest()
        }
        .flatMap { each -> AnyPublisher<[BitcoinChainCryptoAccount], Error> in
            each.map { account, balance -> AnyPublisher<AccountBalanceSpendable, Error> in
                defaultAccountProvider(account.coinType)
                    .flatMap { account -> AnyPublisher<CryptoReceiveAddress, Error> in
                        account.firstReceiveAddress
                            .map { address -> CryptoReceiveAddress in
                                if account.coinType == .bitcoin {
                                    return BitcoinChainReceiveAddress<BitcoinToken>(
                                        address: address.address,
                                        label: address.label,
                                        onTxCompleted: { _ in .just(()) }
                                    )
                                } else {
                                    return BitcoinChainReceiveAddress<BitcoinCashToken>(
                                        address: address.address,
                                        label: address.label,
                                        onTxCompleted: { _ in .just(()) }
                                    )
                                }
                            }
                            .eraseToAnyPublisher()
                    }
                    .flatMap { target -> AnyPublisher<Bool, Error> in
                        let provider = account.coinType == .bitcoin ? btcCandidateProvider : bchCandidateProvider
                        return balanceIsSendable(
                            source: account,
                            target: target,
                            amount: balance,
                            candidateProvider: provider
                        )
                    }
                    .map { isSpendable in
                        AccountBalanceSpendable(account: account, isSpendable: isSpendable)
                    }
                    .eraseToAnyPublisher()
            }
            .combineLatest()
            .map { value in
                value.filter(\.isSpendable)
                    .map(\.account)
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

struct AccountBalanceSpendable {
    let account: BitcoinChainCryptoAccount
    let isSpendable: Bool
}

func balanceIsSpendable(_ balance: CryptoValue?, coin: BitcoinChainCoin) -> Bool {
    guard let balance else { return false }
    return balance.minorAmount > coin.dust && balance.isPositive
}

/// Calculates the fee based on the given amount between source and target
func balanceIsSendable(
    source: BitcoinChainCryptoAccount,
    target: CryptoReceiveAddress,
    amount: MoneyValue,
    candidateProvider: TransactionCandidateProviderAPI
) -> AnyPublisher<Bool, Error> {
    guard let cryptoValue = amount.cryptoValue else {
        return .just(false)
    }
    return candidateProvider.getMaxSpendable(
        sourceAccount: source,
        target: target,
        amount: cryptoValue,
        feeLevel: .regular
    )
    .map { value -> Bool in
        balanceIsSpendable(value, coin: source.coinType)
    }
    .eraseToAnyPublisher()
}

func defaultAccountProvider(coincore: CoincoreAPI) -> (BitcoinChainCoin) -> AnyPublisher<BitcoinChainCryptoAccount, Error> {
    { coinType in
        coincore.accounts(filter: .nonCustodial) { account in
            guard let account = account as? BitcoinChainCryptoAccount else {
                return false
            }
            return account.coinType == coinType && account.isDefault
        }
        .compactMap { $0.first as? BitcoinChainCryptoAccount }
        .eraseToAnyPublisher()
    }
}

// MARK: - Helpers

func btcTxPairs(context: PairsContext, btcAddressProvider: BitcoinChainReceiveAddressProviderAPI) -> AnyPublisher<[TxPair], Error> {
    let btcImported = context.imported.filter { $0.coinType == .bitcoin }
    var receiveIndex = context.btcReceiveIndex
    return btcImported
        .publisher
        .flatMap { imported -> AnyPublisher<TxPair, Error> in
            let pair = btcAddressProvider.receiveAddressProvider(UInt32(context.btcDefaultAccount.hdAccountIndex), receiveIndex: UInt32(receiveIndex))
                .map { address -> TxPair in
                    let target = BitcoinChainReceiveAddress<BitcoinToken>(address: address, label: "", onTxCompleted: { _ in .just(()) })
                    return TxPair(importedAddress: imported, target: target)
                }
                .prefix(1)
                .eraseToAnyPublisher()
            receiveIndex += 1
            return pair
        }
        .collect()
        .eraseToAnyPublisher()
}

func bchTxPairs(context: PairsContext, bchAddressProvider: BitcoinChainReceiveAddressProviderAPI) -> AnyPublisher<[TxPair], Error> {
    let bchImported = context.imported.filter { $0.coinType == .bitcoinCash }
    var receiveIndex = context.bchReceiveIndex
    return bchImported
        .publisher
        .flatMap { imported in
            let pair = bchAddressProvider.receiveAddressProvider(UInt32(context.bchDefaultAccount.hdAccountIndex), receiveIndex: UInt32(receiveIndex))
                .map { address -> TxPair in
                    let target = BitcoinChainReceiveAddress<BitcoinCashToken>(address: address, label: "", onTxCompleted: { _ in .just(()) })
                    return TxPair(importedAddress: imported, target: target)
                }
                .prefix(1)
                .eraseToAnyPublisher()
            receiveIndex += 1
            return pair
        }
        .collect()
        .eraseToAnyPublisher()
}

func getLatestReceiveIndexFor(xpub: XPub, using fetcher: FetchMultiAddressFor) -> AnyPublisher<Int, Error> {
    fetcher([xpub])
        .map { data in
            guard let address = data.addresses.first(where: { $0.address == xpub.address }) else {
                return 0
            }
            return address.accountIndex ?? 0
        }
        .eraseError()
        .eraseToAnyPublisher()
}

// MARK: - Models

struct ImportedAccountAndBalance {
    let account: BitcoinChainCryptoAccount
    let balance: MoneyValue
}

public struct TxPairResult: Equatable {
    public let accountIdentifier: String
    public let result: Result<EmptyValue, Error>

    public init(accountIdentifier: String, result: Result<EmptyValue, Error>) {
        self.accountIdentifier = accountIdentifier
        self.result = result
    }

    public static func == (lhs: TxPairResult, rhs: TxPairResult) -> Bool {
        switch (lhs.result, rhs.result) {
        case(.success(.noValue), .success(.noValue)):
            return lhs.accountIdentifier == rhs.accountIdentifier
        case (.failure, .failure):
            return lhs.accountIdentifier == rhs.accountIdentifier
        default:
            return false
        }
    }
}

public struct PairsContext {
    let btcReceiveIndex: Int
    let bchReceiveIndex: Int
    let imported: [BitcoinChainCryptoAccount]
    let btcDefaultAccount: BitcoinChainCryptoAccount
    let bchDefaultAccount: BitcoinChainCryptoAccount
}

public protocol TxPairAPI {
    var importedAddress: BitcoinChainCryptoAccount { get }
    var target: CryptoReceiveAddress { get }
}

public struct TxPair: TxPairAPI, Equatable, Hashable {
    public let importedAddress: BitcoinChainCryptoAccount
    public let target: CryptoReceiveAddress

    init(
        importedAddress: BitcoinChainCryptoAccount,
        target: CryptoReceiveAddress,
        sendSuccess: Bool = false
    ) {
        self.importedAddress = importedAddress
        self.target = target
    }

    public static func == (lhs: TxPair, rhs: TxPair) -> Bool {
        lhs.importedAddress.identifier == rhs.importedAddress.identifier
        && lhs.target.address == rhs.target.address
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(importedAddress.identifier)
        hasher.combine(target.address)
    }
}
