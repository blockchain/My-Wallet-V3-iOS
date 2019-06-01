//
//  SendPaxCoordinator.swift
//  Blockchain
//
//  Created by AlexM on 5/10/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PlatformKit
import EthereumKit
import BigInt
import ERC20Kit

class SendPaxCoordinator {
    
    fileprivate let interface: SendPAXInterface
    fileprivate let serviceProvider: PAXServiceProvider
    fileprivate var services: PAXServices {
        return serviceProvider.services
    }
    
    fileprivate let bag: DisposeBag = DisposeBag()
    
    fileprivate let calculator: SendPaxCalculator
    fileprivate let priceAPI: PriceServiceAPI
    fileprivate var isExecuting: Bool = false
    fileprivate var output: SendPaxOutput?
    
    init(
        interface: SendPAXInterface,
        serviceProvider: PAXServiceProvider = PAXServiceProvider.shared,
        priceService: PriceServiceAPI = PriceServiceClient()
        ) {
        self.interface = interface
        self.calculator = SendPaxCalculator(erc20Service: serviceProvider.services.paxService)
        self.serviceProvider = serviceProvider
        self.priceAPI = priceService
        if let controller = interface as? SendPaxViewController {
            controller.delegate = self
        }
    }
    
    private var fees: Single<EthereumTransactionFee> {
        return services.feeService.fees
    }
}

extension SendPaxCoordinator: SendPaxViewControllerDelegate {
    var rightNavigationCTAType: NavigationCTAType {
        guard isExecuting == false else { return .activityIndicator }
        return output?.model.internalError != nil ? .error : .qrCode
    }
    
    func onLoad() {
        // Load any pending send metadata and prefill
        calculator.status
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak self] status in
                guard let self = self else { return }
                self.isExecuting = status == .executing
                self.interface.apply(updates: [.updateNavigationItems])
            })
            .subscribe()
            .disposed(by: bag)
        
        calculator.output
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.output = result
                self.interface.apply(updates: result.presentationUpdates)
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
        
        calculator.handle(event: .start)
    }
    
    func onAppear() {
        // TODO: Check ETH balance to cover fees. Only fees.
        // Don't care how much PAX they are sending.
        fees.subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] transactionFee in
                guard let self = self else { return }
                let gasPrice = BigUInt(transactionFee.priority.amount)
                let gasLimitContract = BigUInt(transactionFee.gasLimitContract)
                let ethereumTransactionFee = gasPrice * gasLimitContract
                let result = CryptoValue.etherFromWei(string: "\(ethereumTransactionFee)")
                self.interface.apply(updates: [.feeValueLabel(result)])
            }, onError: { error in
                Logger.shared.error(error)
            }).disposed(by: bag)
    }
    
    // TODO: Should be ERCTokenValue
    func onPaxEntry(_ value: CryptoValue?) {
        // TODO: Build transaction
        // swiftlint:disable force_try
        let tokenValue = try! ERC20TokenValue<PaxToken>.init(crypto: value ?? .zero(assetType: .pax))
        calculator.handle(event: .paxValueEntryEvent(tokenValue))
    }
    
    func onFiatEntry(_ value: FiatValue) {
        // TODO: Build transaction
        // TODO: Validate against balance
        calculator.handle(event: .fiatValueEntryEvent(value))
    }
    
    func onAddressEntry(_ value: String?) {
        guard let accountID = value else { return }
        calculator.handle(event: .addressEntryEvent(accountID))
    }
    
    func onSendProposed() {
        guard let model = output?.model else { return }
        guard let proposal = model.proposal else { return }
        interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        priceAPI.fiatPrice(forCurrency: .pax, fiatSymbol: currencyCode)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .map { priceInFiatValue -> BCConfirmPaymentViewModel in
                let priceInFiat = priceInFiatValue.priceInFiat
                let cryptoDisplayValue = proposal.value.value.toDisplayString(includeSymbol: true)
                let fiatValue = proposal.value.value.convertToFiatValue(exchangeRate: priceInFiat)
                let fee = proposal.gasLimit * proposal.gasPrice
                let fiatFee = CryptoValue.etherFromWei(string: "\(fee)")?.convertToFiatValue(exchangeRate: fiatValue)
                
                let cryptoWithFiat = "\(cryptoDisplayValue) (\(fiatValue.toDisplayString(includeSymbol: true, locale: Locale.current)))"
                
                let model = BCConfirmPaymentViewModel(
                    from: LocalizationConstants.SendAsset.myPaxWallet,
                    to: model.address?.rawValue ?? "",
                    totalAmountText: cryptoDisplayValue,
                    fiatTotalAmountText: fiatValue.toDisplayString(includeSymbol: true, locale: Locale.current),
                    cryptoWithFiatAmountText: cryptoWithFiat,
                    amountWithFiatFeeText: fiatFee?.toDisplayString() ?? "",
                    buttonTitle: LocalizationConstants.SendAsset.send,
                    showDescription: false,
                    surgeIsOccurring: false,
                    noteText: nil,
                    warningText: nil,
                    descriptionTitle: nil
                    )!
                return model
            }.subscribe(onSuccess: { [weak self] viewModel in
                guard let self = self else { return }
                self.interface.display(confirmation: viewModel)
                self.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
                }, onError: { error in
                    Logger.shared.error(error)
            }).disposed(by: bag)
    }
    
    func onConfirmSendTapped() {
        guard let model = output?.model else { return }
        guard let proposal = model.proposal else { return }
        guard let address = model.address else { return }
        interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
        services.paxService.transfer(proposal: proposal, to: address)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .do(onDispose: { [weak self] in
                guard let self = self else { return }
                self.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
            })
            .flatMap(weak: self, { (self, candidate) -> Single<EthereumTransactionPublished> in
                return self.services.walletService.send(transaction: candidate)
            })
            .subscribe(onSuccess: { [weak self] published in
                guard let self = self else { return }
                self.calculator.handle(event: .start)
                self.interface.apply(updates: [.hideConfirmationModal,
                                               .showAlertSheetForSuccess])
                Logger.shared.debug("Published PAX transaction: \(published)")
            }, onError: { error in
                Logger.shared.error(error)
            }).disposed(by: bag)
    }
    
    func onRightBarButtonItemTapped() {
        guard let output = output else { return }
        guard let error = output.model.internalError else { return }
        interface.apply(updates: [.showAlertSheetForError(error)])
    }
    
}
