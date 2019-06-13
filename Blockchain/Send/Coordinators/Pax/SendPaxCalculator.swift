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
    
    typealias Model = SendPaxViewModel
    typealias Input = SendPaxInput
    typealias Output = SendPaxOutput
    typealias Event = SendMoniesEventPublic
    
    fileprivate let bag: DisposeBag = DisposeBag()
    
    let status: PublishSubject<Status> = PublishSubject<Status>()
    let output: PublishSubject<SendPaxOutput> = PublishSubject<SendPaxOutput>()
    
    private var tokenAccount: Single<ERC20TokenAccount?> {
        return Single.deferred { [weak self] in
            guard let self = self else {
                return Single.just(nil)
            }
            guard let value = self.currentTokenAccount else {
                return self.erc20Service.tokenAccount
            }
            return Single.just(value)
        }
        .do(onSuccess: { [weak self] account in
            self?.currentTokenAccount = account
        })
    }
    
    private var currentTokenAccount: ERC20TokenAccount?
    private var model: Model
    
    private let priceService: PriceServiceAPI
    private let erc20Service: ERC20Service<PaxToken>
    
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
            let addressStatus: AddressStatus
            if value.isEmpty {
                addressStatus = .empty
            } else if let address = EthereumAccountAddress(rawValue: value) {
                addressStatus = .valid(address)
            } else {
                addressStatus = .invalid
            }
            input.addressStatus = addressStatus
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
        return priceService
            .fiatPrice(
                forCurrency: input.paxAmount.currencyType,
                fiatSymbol: currencyCode
            )
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
        return priceService
            .fiatPrice(
                forCurrency: value.currencyType,
                fiatSymbol: currencyCode
            )
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
        Single.zip(
                validateSingle(input: input),
                tokenAccount
            )
            .flatMap { value -> Single<Output> in
                let (output, account) = value
                var model = output.model
                var presentationUpdates = output.presentationUpdates
                if account?.label != output.model.walletLabel {
                    model.updateWalletLabel(with: account)
                    presentationUpdates.insert(.walletLabel(account?.label))
                }
                let newOutput = Output(
                    presentationUpdates: presentationUpdates,
                    model: model
                )
                return Single.just(newOutput)
            }
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
    
    private func validateSingle(input: Input) -> Single<Output> {
        var viewModel: SendPaxViewModel = SendPaxViewModel(
            input: input
        )
        var updates: Set<SendMoniesPresentationUpdate> = [
            .cryptoValueTextField(input.paxAmount.value),
            .fiatValueTextField(input.fiatAmount),
            .updateNavigationItems
        ]
        return erc20Service.evaluate(amount: input.paxAmount)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { proposal -> Single<ERC20TransactionProposal<PaxToken>> in
                guard case .invalid = input.addressStatus else {
                    return Single.just(proposal)
                }
                throw SendMoniesInternalError.invalidDestinationAddress
            }
            .map { proposal -> Output in
                
                var sendButtonEnabled = false
                
                if case .valid(let address) = input.addressStatus {
                    sendButtonEnabled = true
                    updates.insert(.toAddressTextField(address.rawValue))
                }
                
                sendButtonEnabled = proposal.aboveMinimumSpendable
                
                updates.insert(.sendButtonEnabled(sendButtonEnabled))
                
                viewModel.proposal = proposal
                return Output(presentationUpdates: updates, model: viewModel)
            }
            .catchError { error -> Single<Output> in
                if let error = error as? ERC20ServiceError {
                    let internalError = SendMoniesInternalError(erc20error: error)
                    viewModel.internalError = internalError
                } else if let error = error as? SendMoniesInternalError {
                    viewModel.internalError = error
                }
                
                updates.insert(.sendButtonEnabled(false))
                let output = Output(presentationUpdates: updates, model: viewModel)
                return Single.just(output)
            }
    }
}
