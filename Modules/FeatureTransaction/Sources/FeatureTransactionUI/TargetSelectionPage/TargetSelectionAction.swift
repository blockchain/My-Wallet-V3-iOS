// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import ToolKit

enum TargetSelectionAction: MviAction {

    case sourceAccountSelected(BlockchainAccount, AssetAction)
    case availableTargets([BlockchainAccount])
    case destinationDeselected
    case validateQRScanner(CryptoReceiveAddress)
    case validate(address: String, memo: String?, sourceAccount: BlockchainAccount)
    case destinationSelected(BlockchainAccount)
    case validateBitPayPayload(String, CryptoCurrency)
    case addressValidated(TargetSelectionInputValidation)
    case validBitPayInvoiceTarget(BitPayInvoiceTarget)
    case destinationConfirmed
    case returnToPreviousStep
    case qrScannerButtonTapped
    case resetFlow

    func reduce(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        Logger.shared.debug("!TRANSACTION!>: \(self)")
        switch self {
        case .validateBitPayPayload:
            return oldState
        case .availableTargets(let accounts):
            return oldState
                .update(keyPath: \.availableTargets, value: accounts.compactMap { $0 as? SingleAccount })
        case .sourceAccountSelected(let account, _):
            return oldState
                .update(keyPath: \.sourceAccount, value: account)
        case .destinationSelected(let account):
            let destination = account as! TransactionTarget
            return oldState
                .update(keyPath: \.inputValidated, value: .account(.account(account)))
                .update(keyPath: \.destination, value: destination)
                .update(keyPath: \.nextEnabled, value: true)
        case .destinationDeselected:
            return oldState
                .update(keyPath: \.destination, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
        case .destinationConfirmed:
            return oldState
                .update(keyPath: \.step, value: .complete)
        case .validateQRScanner(let cryptoReceiveAddress):
            return oldState
                .update(keyPath: \.inputValidated, value: .QR(.valid(cryptoReceiveAddress)))
                .update(keyPath: \.destination, value: cryptoReceiveAddress)
                .update(keyPath: \.nextEnabled, value: true)
        case .validate(let address, let memo, _):
            var memoInput: TargetSelectionInputValidation.MemoInput = .inactive
            if let memo {
                memoInput = .invalid(memo)
            }
            return oldState
                .update(keyPath: \.inputValidated, value: .text(.invalid(address), memoInput, nil))
        case .addressValidated(let inputValidation):
            switch inputValidation {
            case .text(.valid, .valid, let receiveAddress):
                return oldState
                    .update(keyPath: \.inputValidated, value: inputValidation)
                    .update(keyPath: \.destination, value: receiveAddress)
                    .update(keyPath: \.nextEnabled, value: true)
            case .text:
                return oldState
                    .update(keyPath: \.destination, value: nil)
                    .update(keyPath: \.inputValidated, value: inputValidation)
                    .update(keyPath: \.nextEnabled, value: false)
            default:
                impossible(".addressValidated is only called with a TargetSelectionInputValidation.text")
            }
        case .validBitPayInvoiceTarget(let invoice):
            return oldState
                .update(keyPath: \.destination, value: invoice)
                .update(keyPath: \.nextEnabled, value: true)
        case .returnToPreviousStep:
            return oldState
                .update(keyPath: \.step, value: .initial)
                .update(keyPath: \.isGoingBack, value: oldState.step != .qrScanner ? true : false)
        case .qrScannerButtonTapped:
            return oldState
                .update(keyPath: \.inputValidated, value: .QR(.empty))
                .update(keyPath: \.step, value: .qrScanner)
        case .resetFlow:
            return oldState
                .update(keyPath: \.step, value: .closed)
        }
    }
}
