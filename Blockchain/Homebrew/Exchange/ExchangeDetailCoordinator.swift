//
//  ExchangeDetailCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeDetailCoordinatorDelegate: class {
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, updated models: [ExchangeCellModel])
    func coordinator(_ detailCoordinator: ExchangeDetailCoordinator, completedTransaction: OrderTransaction)
}

class ExchangeDetailCoordinator: NSObject {
    
    enum Event {
        case pageLoaded(ExchangeDetailViewController.PageModel)
        case confirmExchange(OrderTransaction)
        case updateConfirmDetails(OrderTransaction, Conversion)
    }

    enum Action {
        case confirmExchange
        case sentTransaction
    }

    fileprivate weak var delegate: ExchangeDetailCoordinatorDelegate?
    fileprivate weak var interface: ExchangeDetailInterface?
    let tradeExecution: TradeExecutionAPI
    fileprivate var accountRepository: AssetAccountRepository {
        get {
            return AssetAccountRepository.shared
        }
    }
    
    init(
        delegate: ExchangeDetailCoordinatorDelegate,
        interface: ExchangeDetailInterface,
        dependencies: ExchangeDependencies
    ) {
        self.delegate = delegate
        self.interface = interface
        self.tradeExecution = dependencies.tradeExecution
        super.init()
    }

// swiftlint:disable function_body_length
    func handle(event: Event) {
        switch event {
        case .updateConfirmDetails(let orderTransaction, let conversion):
            interface?.mostRecentConversion = conversion
            handle(event: .pageLoaded(.confirm(orderTransaction, conversion, tradeExecution)))
        case .pageLoaded(let model):
            
            // TODO: These are placeholder `ViewModels`
            // and are not to be shipped. That being said,
            // they do demonstrate how to use `ExchangeCellModel`
            // to display the correct cellTypes.
            
            var cellModels: [ExchangeCellModel] = []
            
            switch model {
            case .confirm(let orderTransaction, let conversion, _):
                interface?.updateBackgroundColor(#colorLiteral(red: 0.89, green: 0.95, blue: 0.97, alpha: 1))
                interface?.updateTitle(LocalizationConstants.Exchange.confirmExchange)
                
                let pair = ExchangeCellModel.TradingPair(
                    model: TradingPairView.confirmationModel(for: conversion)
                )

                let value = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.value,
                    value: valueString(for: conversion.quote.currencyRatio.counter.fiat.value, currencyCode: conversion.quote.currencyRatio.counter.fiat.symbol)
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.estimatedFees,
                    value: orderTransaction.fees + " " + orderTransaction.from.address.assetType.symbol
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.receive,
                    value: orderTransaction.amountToReceive + " " + TradingPair(string: conversion.quote.pair)!.to.symbol,
                    bold: true
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.sendTo,
                    value: accountRepository.nameOfAccountContaining(address: orderTransaction.destination)
                )
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributedTextFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16.0)
                    ?? UIFont.systemFont(ofSize: 16.0, weight: .regular)
                let attributedText = NSAttributedString(
                    string: LocalizationConstants.Exchange.amountVariation +  " \n\n " + LocalizationConstants.Exchange.orderStartDisclaimer,
                    attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.64, green: 0.64, blue: 0.64, alpha: 1),
                                 NSAttributedStringKey.font: attributedTextFont,
                                 NSAttributedStringKey.paragraphStyle: paragraphStyle]
                )
                
                let text = ExchangeCellModel.Text(
                    attributedString: attributedText
                )
                
                cellModels.append(contentsOf: [
                    .tradingPair(pair),
                    .plain(value),
                    .plain(fees),
                    .plain(receive),
                    .plain(sendTo),
                    .text(text)
                    ]
                )

                interface?.mostRecentOrderTransaction = orderTransaction
                interface?.mostRecentConversion = conversion

                delegate?.coordinator(self, updated: cellModels)
            case .locked(let orderTransaction, let conversion):
                interface?.updateBackgroundColor(.brandPrimary)
                interface?.updateTitle(LocalizationConstants.Exchange.exchangeLocked)
                interface?.navigationBarVisibility(.hidden)
                
                let pair = ExchangeCellModel.TradingPair(
                    model: TradingPairView.confirmationModel(for: conversion)
                )
                
                let value = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.value,
                    value: valueString(for: conversion.quote.currencyRatio.counter.fiat.value, currencyCode: conversion.quote.currencyRatio.counter.fiat.symbol)
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.fees,
                    value: orderTransaction.fees + " " + orderTransaction.from.address.assetType.symbol
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.receive,
                    value: orderTransaction.amountToReceive + " " + TradingPair(string: conversion.quote.pair)!.to.symbol,
                    bold: true
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.sendTo,
                    value: accountRepository.nameOfAccountContaining(address: orderTransaction.destination)
                )
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributedTextFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16.0)
                    ?? UIFont.systemFont(ofSize: 16.0, weight: .regular)
                let attributedText = NSAttributedString(
                    string: LocalizationConstants.Exchange.amountVariation +  " \n\n " + LocalizationConstants.Exchange.orderStartDisclaimer,
                    attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                                 NSAttributedStringKey.font: attributedTextFont,
                                 NSAttributedStringKey.paragraphStyle: paragraphStyle]
                )
                
                let text = ExchangeCellModel.Text(
                    attributedString: attributedText
                )
                
                cellModels.append(contentsOf: [
                    .tradingPair(pair),
                    .plain(value),
                    .plain(fees),
                    .plain(receive),
                    .plain(sendTo),
                    .text(text)
                    ]
                )
                
                delegate?.coordinator(self, updated: cellModels)
            case .overview(let trade):
                interface?.updateBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                interface?.updateTitle(trade.amountReceivedCryptoValue + LocalizationConstants.Exchange.orderID + " " + trade.identifier)
                interface?.navigationBarVisibility(.visible)
                
                let status = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.status,
                    value: trade.status.displayValue,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    statusVisibility: .visible,
                    statusTintColor: trade.status.tintColor
                )
                
                let value = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.value,
                    value: valueString(for: trade.amountFiatValue, currencyCode: trade.amountFiatSymbol),
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let exchange = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.exchange,
                    value: trade.amountDepositedCryptoValue + " " + trade.amountDepositedCryptoSymbol,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.receive,
                    value: trade.amountReceivedCryptoValue + " " + trade.amountReceivedCryptoSymbol,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    bold: true
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.fees,
                    value: trade.amountFeeValue + " " + trade.amountFeeSymbol,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.sendTo,
                    value: accountRepository.nameOfAccountContaining(address: trade.withdrawalAddress),
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )

                var orderId = ExchangeCellModel.Plain(
                    description: LocalizationConstants.Exchange.orderID,
                    value: trade.identifier,
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                orderId.descriptionActionBlock = {
                    guard let text = $0.text else { return }
                    UIPasteboard.general.string = text
                    $0.animate(
                        fromText: trade.identifier,
                        toIntermediateText: LocalizationConstants.copiedToClipboard,
                        speed: 1,
                        gestureReceiver: $0
                    )
                }
                
                cellModels.append(contentsOf: [
                    .plain(status),
                    .plain(value),
                    .plain(exchange),
                    .plain(receive),
                    .plain(fees),
                    .plain(sendTo),
                    .plain(orderId)
                    ]
                )
                
                delegate?.coordinator(self, updated: cellModels)
            }
        case .confirmExchange(let transaction):
            guard let lastConversion = interface?.mostRecentConversion else {
                Logger.shared.error("No conversion to use")
                return
            }
            guard tradeExecution.isExecuting == false else { return }
            interface?.loadingVisibility(.visible, action: .confirmExchange)
            
            tradeExecution.submitAndSend(
                with: lastConversion,
                success: { [weak self] in
                    guard let this = self else { return }
                    
                    NotificationCenter.default.post(
                        Notification(name: Constants.NotificationKeys.exchangeSubmitted)
                    )
                    
                    this.interface?.loadingVisibility(.hidden, action: .confirmExchange)
                    ExchangeCoordinator.shared.handle(
                        event: .sentTransaction(
                            orderTransaction: transaction,
                            conversion: lastConversion
                        )
                    )
                    this.delegate?.coordinator(this, completedTransaction: transaction)
            }) { [weak self] errorDescription in
                guard let this = self else { return }
                this.interface?.loadingVisibility(.hidden, action: .confirmExchange)
                AlertViewPresenter.shared.standardError(message: errorDescription)
            }
        }
    }
}
// swiftlint:enable function_body_length

extension ExchangeDetailCoordinator {
    // TICKET: IOS-1328 Find a better place for this
    func valueString(for amount: String, currencyCode: String) -> String {
        if let currencySymbol =  BlockchainSettings.sharedAppInstance().fiatSymbolFromCode(currencyCode: currencyCode) {
            // $2.34
            return currencySymbol + amount
        } else {
            // 2.34 USD
            return amount + " " + currencyCode
        }
    }
}
