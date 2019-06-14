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
    
    /// Aggregates the amounts before displaying them
    private struct DisplayAmounts {
        let fee: String
        let cryptoAmount: String
        let fiatAmount: String
        
        var totalAmount: String {
            return "\(cryptoAmount) (\(fiatAmount))"
        }
    }
    
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
    
    private var fees: Single<EthereumTransactionFee> {
        return services.feeService.fees
    }
    
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
}

// MARK: - Private

extension SendPaxCoordinator {
    
    /// Fetches updated transaction and fee amounts for display purpose
    private var displayAmounts: Single<DisplayAmounts> {
        let currencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        return Single.zip(
                priceAPI.fiatPrice(forCurrency: .ethereum, fiatSymbol: currencyCode),
                priceAPI.fiatPrice(forCurrency: .pax, fiatSymbol: currencyCode),
                fees
            )
            .map { (ethPrice, paxPrice, etherTransactionFee) -> (FiatValue, FiatValue, EthereumTransactionFee) in
                return (ethPrice.priceInFiat, paxPrice.priceInFiat, etherTransactionFee)
            }
            .map { [weak self] (ethFiatPrice, paxFiatPrice, etherTransactionFee) -> DisplayAmounts in
                let gasPrice = BigUInt(etherTransactionFee.priority.amount)
                let gasLimit = BigUInt(etherTransactionFee.gasLimitContract)
                let fee = gasPrice * gasLimit
                
                let etherFee = CryptoValue.etherFromWei(string: "\(fee)")
                let fiatFee = etherFee?.convertToFiatValue(exchangeRate: ethFiatPrice)
                let fiatDisplayFee = fiatFee?.toDisplayString(includeSymbol: true) ?? ""
                let etherDisplayFee = etherFee?.toDisplayString(includeSymbol: true) ?? ""
                let displayFee = "\(etherDisplayFee) (\(fiatDisplayFee))"
                
                // In case
                let value = self?.output?.model.proposal?.value.value
                let cryptoAmount = value?.toDisplayString(includeSymbol: true) ?? ""
                let fiatValue = value?.convertToFiatValue(exchangeRate: paxFiatPrice)
                let fiatAmount = fiatValue?.toDisplayString(includeSymbol: true) ?? ""
                
                return DisplayAmounts(fee: displayFee, cryptoAmount: cryptoAmount, fiatAmount: fiatAmount)
            }
            .observeOn(MainScheduler.asyncInstance)
    }
}

extension SendPaxCoordinator: SendPaxViewControllerDelegate {
    var rightNavigationCTAType: NavigationCTAType {
        guard isExecuting == false else { return .activityIndicator }
        return output?.model.internalError != nil ? .error : .qrCode
    }
    
    func onLoad() {
        interface.apply(updates: [.maxAvailable(nil)])

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
        let fiatCurrencyCode = BlockchainSettings.App.shared.fiatCurrencyCode
        interface.apply(updates: [.fiatCurrencyLabel(fiatCurrencyCode)])
        
        // TODO: Check ETH balance to cover fees. Only fees.
        // Don't care how much PAX they are sending.
        displayAmounts
            .subscribe(onSuccess: { [weak self] amounts in
                self?.interface.apply(updates: [.feeValueLabel(amounts.fee)])
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
        
        services.assetAccountRepository
            .assetAccountDetails
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] details in
                self?.interface.apply(updates: [.maxAvailable(details.balance)])
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
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
        guard let address = model.addressStatus.address else {
            interface.apply(updates: [.showAlertSheetForError(.invalidDestinationAddress)])
            return
        }
        interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
        
        displayAmounts
            .map { amounts -> BCConfirmPaymentViewModel in
                let model = BCConfirmPaymentViewModel(
                    from: LocalizationConstants.SendAsset.myPaxWallet,
                    to: address.rawValue,
                    totalAmountText: amounts.cryptoAmount,
                    fiatTotalAmountText: amounts.fiatAmount,
                    cryptoWithFiatAmountText: amounts.totalAmount,
                    amountWithFiatFeeText: amounts.fee,
                    buttonTitle: LocalizationConstants.SendAsset.send,
                    showDescription: false,
                    surgeIsOccurring: false,
                    showsFeeInformationButton: false,
                    noteText: nil,
                    warningText: nil,
                    descriptionTitle: nil
                )!
                return model
            }
            .subscribe(onSuccess: { [weak self] viewModel in
                self?.interface.display(confirmation: viewModel)
                self?.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
            }, onError: { [weak self]  error in
                Logger.shared.error(error)
                self?.interface.apply(updates: [.showAlertSheetForError(SendMoniesInternalError.default)])
            })
            .disposed(by: bag)
    }
    
    func onConfirmSendTapped() {
        guard let model = output?.model else { return }
        guard let proposal = model.proposal else { return }
        guard case .valid(let address) = model.addressStatus else { return }
        interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
        services.paxService.transfer(proposal: proposal, to: address.ethereumAddress)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                return self.services.walletService.send(transaction: candidate)
            }
            .do(onDispose: { [weak self] in
                guard let self = self else { return }
                self.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
            })
            .subscribe(onSuccess: { [weak self] published in
                guard let self = self else { return }
                self.calculator.handle(event: .start)
                self.interface.apply(updates: [.hideConfirmationModal,
                                               .toAddressTextField(nil),
                                               .showAlertSheetForSuccess])
                Logger.shared.debug("Published PAX transaction: \(published)")
            }, onError: { [weak self] error in
                Logger.shared.error(error)
                self?.interface.apply(updates: [.showAlertSheetForError(SendMoniesInternalError.default)])
            })
            .disposed(by: bag)
    }
    
    func onErrorBarButtonItemTapped() {
        guard let output = output else { return }
        guard let error = output.model.internalError else { return }
        interface.apply(updates: [.showAlertSheetForError(error)])
    }
    
    func onQRBarButtonItemTapped() {
        interface.displayQRCodeScanner()
    }
}
