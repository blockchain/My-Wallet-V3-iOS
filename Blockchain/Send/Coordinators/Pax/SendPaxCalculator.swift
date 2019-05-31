//
//  SendPaxCalculator.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import EthereumKit
import BigInt
import ERC20Kit

enum SendMoniesEventPublic {
    case start
    /// The user altered the address entry field.
    case addressEntryEvent(String)
    /// The user altered the PAX send amount
    case paxValueEntryEvent(ERC20TokenValue<PaxToken>)
    /// The user aletered the ETH send amount
    case fiatValueEntryEvent(FiatValue)
}

class SendPaxCalculator {
    
    enum Status {
        case executing
        case stopped
    }
    
    typealias Address = EthereumKit.EthereumAddress
    typealias Model = SendPaxViewModel
    typealias Input = SendPaxInput
    typealias Output = SendPaxOutput
    typealias TransactionProposal = ERC20TransactionProposal<PaxToken>
    typealias Event = SendMoniesEventPublic
    
    fileprivate let bag: DisposeBag = DisposeBag()
    
    let status: PublishSubject<Status> = PublishSubject<Status>()
    let output: PublishSubject<SendPaxOutput> = PublishSubject<SendPaxOutput>()
    
    private let priceService: PriceServiceAPI
    private let erc20Service: ERC20Service<PaxToken>
    private var model: Model
    
    init(serviceAPI: PriceServiceAPI = PriceServiceClient(),
         erc20Service: ERC20Service<PaxToken>,
         input: Input = .empty) {
        self.priceService = serviceAPI
        self.erc20Service = erc20Service
        self.model = SendPaxViewModel(input: input)
    }
    
    func handle(event: Event) {
        /// On handling we should show the activity indicator
        /// in the NavigationBarButtonItem to indicate
        /// that input is being validated.
        status.on(.next(.executing))
        switch event {
        case .start:
            model = SendPaxViewModel(input: .empty)
            validate(input: model.input)
        case .fiatValueEntryEvent(let value):
            updateFiatValue(value)
                .subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { self.validate(input: $0) })
                .disposed(by: bag)
        case .paxValueEntryEvent(let value):
            updatePaxValue(value)
                .subscribeOn(MainScheduler.instance)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { self.validate(input: $0) })
                .disposed(by: bag)
        case .addressEntryEvent(let value):
            var input = model.input
            input.address = Address(stringLiteral: value)
            validate(input: input)
        }
    }
    
    /// Takes the user provided `FiatValue` and returns a `SendPaxOutput`.
    /// Updating the `FiatValue` requires the `CryptoValue` to be updated
    /// based on the current exchange rate.
    private func updateFiatValue(_ value: FiatValue) -> Observable<SendPaxInput> {
        
        var input = model.input
        /// Conversion completed regardless of user ETH or token balance
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        /// Conversion completed regardless of user ETH or token balance
        return priceService.fiatPrice(
            forCurrency: input.paxAmount.currencyType,
            fiatSymbol: currencyCode)
            .asObservable()
            .flatMapLatest { priceInFiatValue -> Observable<SendPaxInput> in
                let exchangeRate = priceInFiatValue.priceInFiat.amount
                let majorValue = value.amount * exchangeRate
                let cryptoValue = CryptoValue.createFromMajorValue(majorValue, assetType: .pax)
                input.fiatAmount = value
                // swiftlint:disable force_try
                input.paxAmount = try! ERC20TokenValue<PaxToken>(crypto: cryptoValue)
                return Observable.just(input)
        }
    }
    
    private func updatePaxValue(_ value: ERC20TokenValue<PaxToken>) -> Observable<SendPaxInput> {
        
        var input = model.input
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        /// Conversion completed regardless of user ETH or token balance
        return priceService.fiatPrice(
            forCurrency: value.currencyType,
            fiatSymbol: currencyCode)
            .asObservable()
            .flatMapLatest { priceInFiatValue -> Observable<SendPaxInput> in
                let fiatValue = priceInFiatValue.priceInFiat
                let cryptoValue = value.value
                let converted = cryptoValue.convertToFiatValue(exchangeRate: fiatValue)
                input.fiatAmount = converted
                input.paxAmount = value
                return Observable.just(input)
        }
    }
    
    /// Can error from insufficient balances
    /// Invalid destination address
    /// Error getting wallet account info
    /// misc.
    private func validate(input: Input) {
        var viewModel: SendPaxViewModel = SendPaxViewModel(input: input)
        var updates: Set<SendMoniesPresentationUpdate> = [
            .cryptoValueTextField(input.paxAmount.value),
            .fiatValueTextField(input.fiatAmount),
            .updateNavigationItems
        ]
        
        erc20Service.evaluate(amount: input.paxAmount)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .map({ proposal -> Output in
                if let address = input.address, address.isValid {
                    updates.insert(.sendButtonEnabled(true))
                    updates.insert(.toAddressTextField(address.rawValue))
                } else {
                    updates.insert(.sendButtonEnabled(false))
                    viewModel.internalError = .invalidDestinationAddress
                }
                viewModel.proposal = proposal
                return Output(presentationUpdates: updates, model: viewModel)
            })
            .catchError({ error -> Single<Output> in
                if let error = error as? ERC20ServiceError {
                    let internalError = SendMoniesInternalError(erc20error: error)
                    viewModel.internalError = internalError
                }
                
                updates.insert(.sendButtonEnabled(false))
                let output = Output(presentationUpdates: updates, model: viewModel)
                return Single.just(output)
            })
            .subscribe(onSuccess: { value in
                self.model = value.model
                self.output.on(.next(value))
                self.status.on(.next(.stopped))
            }, onError: { error in
                /// ⚠️ Errors that occur here are not handled as they are not
                /// being applied to the `Model`. Most, if not all errors should
                /// be applied to the `Model` as the `SendPaxViewController` must
                /// know what error occured in order to show the proper alert.
                Logger.shared.error(error)
                self.output.on(.error(error))
                self.status.on(.next(.stopped))
            })
            .disposed(by: bag)
    }
}
