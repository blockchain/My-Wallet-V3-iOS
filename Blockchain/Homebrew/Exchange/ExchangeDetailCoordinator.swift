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
}

class ExchangeDetailCoordinator: NSObject {
    
    enum Event {
        case pageLoaded(ExchangeDetailViewController.PageModel)
        case confirmExchange(OrderTransaction, Conversion)
        case updateConfirmDetails(OrderTransaction, Conversion)
    }

    enum Action {
        case confirmExchange
        case sentTransaction
    }

    fileprivate weak var delegate: ExchangeDetailCoordinatorDelegate?
    fileprivate weak var interface: ExchangeDetailInterface?
    let tradeExecution: TradeExecutionAPI
    
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
            handle(event: .pageLoaded(.confirm(orderTransaction, conversion)))
        case .pageLoaded(let model):
            
            // TODO: These are placeholder `ViewModels`
            // and are not to be shipped. That being said,
            // they do demonstrate how to use `ExchangeCellModel`
            // to display the correct cellTypes.
            
            var cellModels: [ExchangeCellModel] = []
            
            switch model {
            case .confirm(let orderTransaction, let conversion):
                
                interface?.updateBackgroundColor(#colorLiteral(red: 0.89, green: 0.95, blue: 0.97, alpha: 1))
                interface?.updateTitle("Confirm Exchange")
                
                let pair = ExchangeCellModel.TradingPair(
                    model: TradingPairView.confirmationModel(for: conversion)
                )
                
                let value = ExchangeCellModel.Plain(
                    description: "Value",
                    value: "$" + ((conversion.quote.fix == .base || conversion.quote.fix == .baseInFiat) ?
                        conversion.quote.currencyRatio.base.fiat.value :
                        conversion.quote.currencyRatio.counter.fiat.value)
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: "Fees",
                    value: orderTransaction.fees + " " + orderTransaction.from.address.assetType.symbol
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: "Receive",
                    value: orderTransaction.amountToReceive + " " + TradingPair(string: conversion.quote.pair)!.to.symbol,
                    bold: true
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: "Send to",
                    value: "My Wallet"
                )
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributedTextFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16.0)
                    ?? UIFont.systemFont(ofSize: 16.0, weight: .regular)
                let attributedText = NSAttributedString(
                    string: "The amounts you send and receive may change slightly due to market activity.\n\n Once an order starts, we are unable to stop it.",
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

                delegate?.coordinator(self, updated: cellModels)
            case .locked(let trade):
                interface?.updateBackgroundColor(.brandPrimary)
                interface?.updateTitle(LocalizationConstants.Exchange.exchangeLocked)
                interface?.navigationBarVisibility(.hidden)
                
                let pair = ExchangeCellModel.TradingPair(
                    model: TradingPairView.exchangeLockedModel(for: trade)
                )
                
                let value = ExchangeCellModel.Plain(
                    description: "Value",
                    value: "$1,624.50"
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: "Fees",
                    value: "0.000414 BTC"
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: "Receive",
                    value: "5.668586 ETH",
                    bold: true
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: "Send to",
                    value: "My Wallet"
                )
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributedTextFont = UIFont(name: Constants.FontNames.montserratRegular, size: 16.0)
                    ?? UIFont.systemFont(ofSize: 16.0, weight: .regular)
                let attributedText = NSAttributedString(
                    string: "The amounts you send and receive may change slightly due to market activity.\n\n Once an order starts, we are unable to stop it.",
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
                interface?.updateTitle(LocalizationConstants.Exchange.orderID + " " + trade.identifier)
                interface?.navigationBarVisibility(.visible)
                
                let status = ExchangeCellModel.Plain(
                    description: "Status",
                    value: "Complete",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    statusVisibility: .visible
                )
                
                let value = ExchangeCellModel.Plain(
                    description: "Value",
                    value: "$1,642.50",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let exchange = ExchangeCellModel.Plain(
                    description: "Exchange",
                    value: "$0.25 BTC",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let receive = ExchangeCellModel.Plain(
                    description: "Receive",
                    value: "5.668586",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1),
                    bold: true
                )
                
                let fees = ExchangeCellModel.Plain(
                    description: "Fees",
                    value: "0.000414 BTC",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                let sendTo = ExchangeCellModel.Plain(
                    description: "Send to",
                    value: "My Wallet",
                    backgroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9607843137, alpha: 1)
                )
                
                cellModels.append(contentsOf: [
                    .plain(status),
                    .plain(value),
                    .plain(exchange),
                    .plain(receive),
                    .plain(fees),
                    .plain(sendTo)
                    ]
                )
                
                delegate?.coordinator(self, updated: cellModels)
            }
        case .confirmExchange(let orderTransaction, _):
            tradeExecution.sendTransaction(assetType: orderTransaction.to.assetType, success: {
                ExchangeCoordinator.shared.handle(event: .sentTransaction)
            }) { error in
                AlertViewPresenter.shared.standardError(message: error)
            }
        }
    }
}
// swiftlint:enable function_body_length
