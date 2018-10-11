//
//  MarketsService.swift
//  Blockchain
//
//  Created by kevinwu on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ExchangeMarketsAPI {
    func setup()
    func authenticate(completion: @escaping () -> Void)

    /// Unsubscribes from receiving conversion updates for the currency pair `pair`
    ///
    /// - Parameter pair: the currency pair (e.g. "BTC-ETH")
    func unsubscribeToCurrencyPair(pair: String)

    /// Computes the fiat balance in `fiatCurrency` for the provided `assetAccount` balance.
    /// This method will return an Observable which reports different fiat balances as
    /// the exchange rate changes.
    ///
    /// - Parameters:
    ///   - assetAccount: the AssetAccount
    ///   - fiatCurrencyCode: the currency code to compute the balance in (e.g. "USD")
    /// - Returns: an Observable returning the fiat balance
    func fiatBalance(forAssetAccount assetAccount: AssetAccount, fiatCurrencyCode: String) -> Observable<Decimal>

    /// Returns the best exchange rates for all crypto-to-crypto and crypto-to-fiat pairs.
    ///
    /// - Parameter fiatCurrencyCode: the currency code for retrieving crypto-to-fiat rates
    /// - Returns: an Observable emitting the best exchanges rates as they reported through the websocket
    func bestExchangeRates(fiatCurrencyCode: String) -> Observable<ExchangeRates>

    var hasAuthenticated: Bool { get }
    var conversions: Observable<Conversion> { get }
    var errors: Observable<SocketError> { get }
    func updateConversion(model: MarketsModel)
}

// MarketsService provides information about crypto/fiat trading data via observables.
// Data can include volume, price, and conversion rates given a quantity, trading pair and
// designated base or counter.
// This class is intended to provide observables for both websockets and REST endpoints.
// Ideally the caller should not care whether websockets or REST is used
// The DataSource enum should default first to websockets, then to REST as fallback.
class MarketsService {

    private let restMessageSubject = PublishSubject<Conversion>()
    private let authentication: NabuAuthenticationService
    private let socketManager: SocketManager
    private let cachedExchangeRates = BehaviorRelay<ExchangeRates?>(value: nil)
    private let disposables = CompositeDisposable()

    private var socketMessageObservable: Observable<SocketMessage> {
        return SocketManager.shared.webSocketMessageObservable
    }

    private var dataSource: DataSource = .socket

    var hasAuthenticated: Bool = false

    init(
        authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
        socketManager: SocketManager = SocketManager.shared
    ) {
        self.authentication = authenticationService
        self.socketManager = socketManager
    }

    deinit {
        disposables.dispose()
        socketManager.disconnect(socketType: .exchange)
    }
}

// MARK: - Setup
extension MarketsService {
    func setup() {
        socketManager.setupSocket(socketType: .exchange, url: URL(string: BlockchainAPI.shared.retailCoreSocketUrl)!)
    }
}

// MARK: - Data sourcing
private extension MarketsService {
    // Two ways of retrieving data.
    enum DataSource {
        case socket // Using websockets, which is the default dataSource
        case rest // Using REST endpoints, which is the fallback dataSource
    }
}

// MARK: - Public API
extension MarketsService: ExchangeMarketsAPI {
    // MARK: - Authentication
    func authenticate(completion: @escaping () -> Void) {
        switch dataSource {
        case .socket: do {
            subscribeToHeartBeat(completion: completion)
            authenticateSocket()
        }
        case .rest: Logger.shared.debug("use REST endpoint")
        }
    }

    // MARK: - Conversion
    var conversions: Observable<Conversion> {
        switch dataSource {
        case .socket:
            return socketMessageObservable.filter {
                $0.type == .exchange &&
                    $0.JSONMessage is Conversion
            }.map { message in
                return message.JSONMessage as! Conversion
            }
        case .rest:
            return restMessageSubject.filter({ _ -> Bool in
                return false
            })
        }
    }
    
    var errors: Observable<SocketError> {
        // TODO: handle REST
        // TICKET: IOS-1320
        return socketMessageObservable.filter {
            $0.type == .exchange &&
                $0.JSONMessage is SocketError
            }.map { message in
                return message.JSONMessage as! SocketError
        }
    }

    private var exchangeRatesObservable: Observable<ExchangeRates> {
        // TODO: handle REST
        // TICKET: IOS-1320
        return socketMessageObservable.filter {
            $0.type == .exchange
        }.filter {
            $0.JSONMessage is ExchangeRates
        }.map {
            $0.JSONMessage as! ExchangeRates
        }.do(onNext: { [weak self] exchangeRates in
            self?.cachedExchangeRates.accept(exchangeRates)
        })
    }

    func bestExchangeRates(fiatCurrencyCode: String) -> Observable<ExchangeRates> {

        // Send exchange_rates socket message - get exchange rates for all possible pairs
        sendBestExchangeRatesSocketMessage(fiatCurrencyCode: fiatCurrencyCode)

        // Return exchange rates observable and start with cached rates if available
        var exchangeRates = exchangeRatesObservable
        if let cachedExchangeRates = cachedExchangeRates.value {
            exchangeRates = exchangeRates.startWith(cachedExchangeRates)
        }
        return exchangeRates
    }

    private func sendBestExchangeRatesSocketMessage(fiatCurrencyCode: String) {
        let allAssetTypes = AssetType.all
        var allPairs: [String] = []

        // Crypto-to-fiat pairs
        let fiatPairs = allAssetTypes.map {
            return "\($0.symbol)-\(fiatCurrencyCode)"
        }
        allPairs.append(contentsOf: fiatPairs)

        // Crypto-to-crypto pairs
        allAssetTypes.forEach { baseType in
            let otherTypes = AssetType.all.filter { $0 != baseType }
            otherTypes.forEach { counterType in
                allPairs.append("\(baseType.symbol)-\(counterType.symbol)")
            }
        }

        let params = CurrencyPairsSubscribeParams(pairs: allPairs)
        let subscribe = Subscription(channel: "exchange_rate", params: params)
        let message = SocketMessage(type: .exchange, JSONMessage: subscribe)
        SocketManager.shared.send(message: message)
    }

    func fiatBalance(forAssetAccount assetAccount: AssetAccount, fiatCurrencyCode: String) -> Observable<Decimal> {

        // Don't need to get exchange rates if the account balance is 0
        guard assetAccount.balance != 0 else {
            return Observable.just(0)
        }

        return bestExchangeRates(fiatCurrencyCode: fiatCurrencyCode).map { rates in
            return rates.convert(
                balance: assetAccount.balance,
                fromCurrency: assetAccount.address.assetType.symbol,
                toCurrency: fiatCurrencyCode
            )
        }
    }

    func updateConversion(model: MarketsModel) {
        switch dataSource {
        case .socket:
            let params = ConversionSubscribeParams(
                type: "conversionSpecification",
                pair: model.pair.stringRepresentation,
                fiatCurrency: model.fiatCurrencyCode,
                fix: model.fix,
                volume: model.volume)
            let quote = Subscription(channel: "conversion", params: params)
            let message = SocketMessage(type: .exchange, JSONMessage: quote)
            SocketManager.shared.send(message: message)
        case .rest:
            Logger.shared.debug("Not yet implemented")
        }
    }

    func unsubscribeToCurrencyPair(pair: String) {
        guard dataSource == .socket else {
            Logger.shared.info("Unsubscribing to a currency pair is only necessary if the data source is WS.")
            return
        }
        let params = ConversionPairUnsubscribeParams(pair: pair)
        let unsubscribeMessage = Unsubscription(channel: "conversion", params: params)
        let socketMessage = SocketMessage(type: .exchange, JSONMessage: unsubscribeMessage)
        SocketManager.shared.send(message: socketMessage)
    }
}

// MARK: - Private API
private extension MarketsService {
    func subscribeToHeartBeat(completion: @escaping () -> Void) {
        let heartBeatDisposable = socketMessageObservable
            .filter { socketMessage in
                return socketMessage.JSONMessage is HeartBeat
            }
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] _ in
                guard let this = self else { return }
                this.hasAuthenticated = true
                completion()
            })

        _ = disposables.insert(heartBeatDisposable)
    }

    func authenticateSocket() {
        let authenticationDisposable = authentication.getSessionToken(requestNewToken: true)
            .map { tokenResponse -> Subscription<AuthSubscribeParams> in
                let params = AuthSubscribeParams(type: "auth", token: tokenResponse.token)
                return Subscription(channel: "auth", params: params)
            }.map { message in
                return SocketMessage(type: .exchange, JSONMessage: message)
            }.subscribe(onSuccess: { socketMessage in
                SocketManager.shared.send(message: socketMessage)
            })

        _ = disposables.insert(authenticationDisposable)
    }
}
