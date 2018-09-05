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
        case pageAppeared(ExchangeDetailViewController.PageModel)
    }
    
    fileprivate weak var delegate: ExchangeDetailCoordinatorDelegate?
    fileprivate weak var interface: ExchangeDetailInterface?
    
    init(
        delegate: ExchangeDetailCoordinatorDelegate,
        interface: ExchangeDetailInterface
        ) {
        self.delegate = delegate
        self.interface = interface
        super.init()
    }
    
    func handle(event: Event) {
        switch event {
        case .pageAppeared(let model):
            
            var cellModels: [ExchangeCellModel] = []
            
            switch model {
            case .confirm(let trade):
                
                interface?.updateBackgroundColor(#colorLiteral(red: 0.89, green: 0.95, blue: 0.97, alpha: 1))
                interface?.updateTitle("Confirm Exchange")
                
                let pair = ExchangeCellModel.TradingPair(
                    model: TradingPairView.confirmationModel(for: trade)
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
                
                let attributedText = NSAttributedString(string: "The amounts you send and receive may change slightly due to market activity.\n\n Once an order starts, we are unable to stop it.")
                
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
            case .locked:
                // TODO
                break
            case .overview:
                // TODO
                break
            }
        }
    }
    
    
}
