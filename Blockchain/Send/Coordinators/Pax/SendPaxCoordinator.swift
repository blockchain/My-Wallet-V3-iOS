//
//  SendPaxCoordinator.swift
//  Blockchain
//
//  Created by AlexM on 5/10/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BigInt
import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

class SendPaxCoordinator {
    
    private let interface: SendPAXInterface
    
    private let analyticsRecorder: AnalyticsEventRecording
    
    private let bag: DisposeBag = DisposeBag()
    private let bus: WalletActionEventBus
    
    private let calculator: SendPaxCalculator
    private let priceAPI: PriceServiceAPI
    private var isExecuting: Bool = false
    private var output: SendPaxOutput?
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let walletService: EthereumWalletServiceAPI
    private let assetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    private let paxService: ERC20Service<PaxToken>
    
    /// The source of the address
    private var addressSource = SendAssetAddressSource.standard
    
    /// Exchange address presenter
    private let exchangeAddressPresenter: SendExchangeAddressStatePresenter
    private var exchangeAddressViewModel = ExchangeAddressViewModel(cryptoCurrency: .pax)

    private var fees: Single<EthereumTransactionFee> {
        feeService.fees
    }
    
    init(
        interface: SendPAXInterface,
        priceService: PriceServiceAPI = resolve(),
        exchangeAddressPresenter: SendExchangeAddressStatePresenter,
        bus: WalletActionEventBus = WalletActionEventBus.shared,
        analyticsRecorder: AnalyticsEventRecording = resolve(),
        feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
        walletService: EthereumWalletServiceAPI = resolve(),
        assetAccountRepository: ERC20AssetAccountRepository<PaxToken> = resolve(),
        paxService: ERC20Service<PaxToken> = resolve()
    ) {
        self.interface = interface
        self.calculator = SendPaxCalculator(erc20Service: resolve())
        self.priceAPI = priceService
        self.exchangeAddressPresenter = exchangeAddressPresenter
        self.bus = bus
        self.analyticsRecorder = analyticsRecorder
        self.feeService = feeService
        self.walletService = walletService
        self.assetAccountRepository = assetAccountRepository
        self.paxService = paxService
        if let controller = interface as? SendPaxViewController {
            controller.delegate = self
        }
    }
}

// MARK: - Private

extension SendPaxCoordinator {
    
    // TODO: Should be calculated inside SendPaxCalculator. Add unit-test!
    /// Contains raw data about fiat, ether, pax and ERC20 account balance
    private struct Metadata {
        let etherInFiat: FiatValue
        let paxInFiat: FiatValue
        let etherFee: CryptoValue?
        let balance: CryptoValue?

        var fiatFee: FiatValue? {
            etherFee?.convertToFiatValue(exchangeRate: etherInFiat)
        }
        
        var paxFee: CryptoValue? {
            fiatFee?.convertToCryptoValue(exchangeRate: paxInFiat, cryptoCurrency: .pax)
        }
        
        init(etherInFiat: FiatValue, paxInFiat: FiatValue, etherFee: EthereumTransactionFee, balance: CryptoValue) {
            self.etherInFiat = etherInFiat
            self.paxInFiat = paxInFiat
            
            let gasPrice = BigUInt(etherFee.priority.amount)
            let gasLimit = BigUInt(etherFee.gasLimitContract)
            let fee = gasPrice * gasLimit
            self.etherFee = CryptoValue.ether(minor: "\(fee)")
            self.balance = balance
        }
        
        func displayData(using erc20Value: CryptoValue? = nil) -> DisplayData {
            // Calculate fees
            let fiatFee = self.fiatFee
            let fiatDisplayFee = fiatFee?.toDisplayString(includeSymbol: true) ?? ""
            let etherDisplayFee = etherFee?.toDisplayString(includeSymbol: true) ?? ""
            let displayFee = "\(etherDisplayFee) (\(fiatDisplayFee))"
            
            // Calculate transaction value
            let cryptoAmount = erc20Value?.toDisplayString(includeSymbol: true) ?? ""
            let fiatValue = erc20Value?.convertToFiatValue(exchangeRate: paxInFiat)
            let fiatAmount = fiatValue?.toDisplayString(includeSymbol: true) ?? ""

            let totalFiatDisplayValue: String
            if let fiatFee = fiatFee, let fiatValue = fiatValue, let totalFiatIncludingFee = try? fiatValue + fiatFee {
                totalFiatDisplayValue = totalFiatIncludingFee.toDisplayString(includeSymbol: true)
            } else {
                totalFiatDisplayValue = ""
            }
            
            let totalCryptoDisplayValue: String
            if let cryptoValue = erc20Value, let cryptoFee = paxFee, let totalCryptoIncludingFee = try? cryptoValue + cryptoFee {
                totalCryptoDisplayValue = totalCryptoIncludingFee.toDisplayString(includeSymbol: true)
            } else {
                totalCryptoDisplayValue = ""
            }
    
            return DisplayData(fee: displayFee,
                               cryptoAmount: cryptoAmount,
                               fiatAmount: fiatAmount,
                               totalFiatIncludingFee: totalFiatDisplayValue,
                               totalCryptoIncludingFee: totalCryptoDisplayValue)
        }
    }
    
    /// Aggregates the data ready for display.
    private struct DisplayData {
        let fee: String
        let cryptoAmount: String
        let fiatAmount: String
        
        var totalFiatIncludingFee: String
        var totalCryptoIncludingFee: String
        
        var totalAmount: String {
            "\(cryptoAmount) (\(fiatAmount))"
        }
    }
    
    /// Returns metadata struct. See `Metadata`.
    private var metadata: Single<Metadata> {
        let balance = assetAccountRepository.assetAccountDetails
            .map { details -> CryptoValue in
                details.balance
            }
            .subscribeOn(MainScheduler.asyncInstance)
            .asObservable()
            .asSingle()

        let fiatCurrency = BlockchainSettings.App.shared.fiatCurrency
        return Single.zip(
            priceAPI.price(for: CryptoCurrency.ethereum, in: fiatCurrency),
            priceAPI.price(for: CryptoCurrency.pax, in: fiatCurrency),
            fees,
            balance
        )
        .map { (ethPrice, paxPrice, etherTransactionFee, balance) -> Metadata in
            Metadata(etherInFiat: ethPrice.moneyValue.fiatValue!,
                            paxInFiat: paxPrice.moneyValue.fiatValue!,
                            etherFee: etherTransactionFee,
                            balance: balance)
        }
    }
    
    /// Fetches updated transaction and fee amounts for display purpose
    private var displayData: Single<DisplayData?> {
        metadata
            .map { [weak self] data in
                data.displayData(using: self?.output?.model.proposal?.value.value)
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
        interface.apply(updates: [.maxAvailable(nil),
                                  .exchangeAddressButtonVisibility(false),
                                  .useExchangeAddress(nil)])

        // Fetch the Exchange address for PAX asset and apply changes to the interface
        exchangeAddressPresenter.viewModel
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] viewModel in
                guard let self = self else { return }
                self.exchangeAddressViewModel = viewModel
                self.interface.apply(updates: [.exchangeAddressButtonVisibility(true)])
            }, onError: { [weak self] error in
                self?.interface.apply(updates: [.exchangeAddressButtonVisibility(false)])
            })
            .disposed(by: bag)
        
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
        
        walletService.fetchHistoryIfNeeded
            .subscribe()
            .disposed(by: bag)
        calculator.handle(event: .resume)
        
        let fiatCurrency = BlockchainSettings.App.shared.fiatCurrency
        interface.apply(updates: [.fiatCurrencyLabel(fiatCurrency.code)])
        
        // TODO: Check ETH balance to cover fees. Only fees.
        // Don't care how much PAX they are sending.
        
        metadata
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { [weak self] data in
                self?.interface.apply(updates: [.maxAvailable(data.balance)])
            })
            .map { $0.displayData() }
            .subscribe(onSuccess: { [weak self] data in
                self?.interface.apply(updates: [.feeValueLabel(data.fee)])
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    // TODO: Should be ERCTokenValue
    func onPaxEntry(_ value: CryptoValue?) {
        // TODO: Build transaction
        // swiftlint:disable force_try
        let tokenValue = try! ERC20TokenValue<PaxToken>.init(crypto: value ?? .paxZero)
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
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmClick(asset: .pax))
        guard let model = output?.model else { return }
        guard let address = model.addressStatus.address else {
            interface.apply(updates: [.showAlertSheetForError(.invalidDestinationAddress)])
            return
        }
        interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
        
        let displayAddress: String
        switch addressSource {
        case .exchange:
            displayAddress = String(
                format: LocalizationConstants.Exchange.Send.destination,
                CryptoCurrency.pax.displayCode
            )
        case .standard:
            displayAddress = address.rawValue
        }
        
        displayData
            .map { data -> BCConfirmPaymentViewModel in
                let model = BCConfirmPaymentViewModel(
                    from: LocalizationConstants.SendAsset.myPaxWallet,
                    destinationDisplayAddress: displayAddress,
                    destinationRawAddress: address.rawValue,
                    totalAmountText: data?.totalCryptoIncludingFee ?? "",
                    fiatTotalAmountText: data?.totalFiatIncludingFee ?? "",
                    cryptoWithFiatAmountText: data?.totalAmount ?? "",
                    amountWithFiatFeeText: data?.fee ?? "",
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
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmSuccess(asset: .pax))
                self.interface.display(confirmation: viewModel)
                self.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
            }, onError: { [weak self]  error in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormConfirmFailure(asset: .pax))
                self.interface.apply(updates: [.showAlertSheetForError(SendMoniesInternalError.default)])
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    func onConfirmSendTapped() {
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmClick(asset: .pax))
        guard let model = output?.model else { return }
        guard let proposal = model.proposal else { return }
        guard case .valid(let address) = model.addressStatus else { return }
        paxService.transfer(proposal: proposal, to: address.ethereumAddress)
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .do(onSubscribe: { [weak self] in
                self?.interface.apply(updates: [.loadingIndicatorVisibility(.visible)])
            })
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.walletService.send(transaction: candidate)
            }
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [weak self] in
                guard let self = self else { return }
                self.interface.apply(updates: [.loadingIndicatorVisibility(.hidden)])
            })
            .subscribe(onSuccess: { [weak self] published in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmSuccess(asset: .pax))
                self.calculator.handle(event: .start)
                self.interface.apply(updates: [.hideConfirmationModal,
                                               .toAddressTextField(nil),
                                               .showAlertSheetForSuccess])
                self.bus.publish(
                    action: .sendCrypto,
                    extras: [WalletAction.ExtraKeys.assetType: CryptoCurrency.pax]
                )
                Logger.shared.debug("Published PAX transaction: \(published)")
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Send.sendSummaryConfirmFailure(asset: .pax))
                self.interface.apply(updates: [.showAlertSheetForError(SendMoniesInternalError.default)])
                Logger.shared.error(error)
            })
            .disposed(by: bag)
    }
    
    func onErrorBarButtonItemTapped() {
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormErrorClick(asset: .pax))
        guard let output = output else { return }
        guard let error = output.model.internalError else { return }
        interface.apply(updates: [.showAlertSheetForError(error)])
    }
    
    func onQRBarButtonItemTapped() {
        analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormQrButtonClick(asset: .pax))
        interface.displayQRCodeScanner()
    }
    
    func onExchangeAddressButtonTapped() {
        switch addressSource {
        case .exchange:
            addressSource = .standard
            interface.apply(updates: [.useExchangeAddress(nil)])
        case .standard:
            analyticsRecorder.record(event: AnalyticsEvents.Send.sendFormExchangeButtonClick(asset: .pax))
            if !exchangeAddressViewModel.isTwoFactorEnabled {
                interface.apply(updates: [.showAlertForEnabling2FA])
            } else {
                addressSource = .exchange
                onAddressEntry(exchangeAddressViewModel.address)
                interface.apply(updates: [.useExchangeAddress(exchangeAddressViewModel.address)])
            }
        }
    }
}
