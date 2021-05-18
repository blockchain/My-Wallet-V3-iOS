//
//  TargetSelectionAction.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/24/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum TargetSelectionAction: MviAction {
    
    case sourceAccountSelected(BlockchainAccount, AssetAction)
    case availableTargets([BlockchainAccount])
    case destinationDeselected
    case validateAddress(String, CryptoAccount)
    case destinationSelected(BlockchainAccount)
    case addressValidated(TargetSelectionPageState.InputValidation)
    case destinationConfirmed
    case returnToPreviousStep
    case qrScannerButtonTapped
    case resetFlow
    
    func reduce(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        switch self {
        case .availableTargets(let accounts):
            return oldState
                .update(keyPath: \.availableTargets, value: accounts.compactMap { $0 as? SingleAccount })
        case .sourceAccountSelected(let account, _):
            return oldState
                .update(keyPath: \.sourceAccount, value: account)
        case .destinationSelected(let account):
            let destination = account as! TransactionTarget
            return oldState
                .update(keyPath: \.destination, value: destination)
                .update(keyPath: \.nextEnabled, value: true)
        case .destinationDeselected:
            return oldState
                .update(keyPath: \.destination, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
        case .destinationConfirmed:
            return oldState.update(keyPath: \.step, value: .complete)
        case .validateAddress:
            return oldState
        case .addressValidated(let inputValidation):
            guard case let .valid(address) = inputValidation else {
                return oldState
                    .update(keyPath: \.inputValidated, value: inputValidation)
                    .update(keyPath: \.nextEnabled, value: false)
            }
            let destination = address as TransactionTarget
            return oldState
                .update(keyPath: \.inputValidated, value: inputValidation)
                .update(keyPath: \.destination, value: destination)
                .update(keyPath: \.nextEnabled, value: true)
        case .returnToPreviousStep:
            var stepsBackStack = oldState.stepsBackStack
            let previousStep = stepsBackStack.popLast() ?? .initial
            return oldState
                .update(keyPath: \.stepsBackStack, value: stepsBackStack)
                .update(keyPath: \.step, value: previousStep)
                .update(keyPath: \.isGoingBack, value: true)
        case .qrScannerButtonTapped:
            return oldState
                .update(keyPath: \.step, value: .qrScanner)
        case .resetFlow:
            return oldState
                .update(keyPath: \.step, value: .closed)
        }
    }
}
