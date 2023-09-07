// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

enum TargetSelectionPageStep: Equatable {
    case initial
    case complete
    case qrScanner
    case closed
}

struct TargetSelectionPageState: Equatable, StateType {

    static let empty = TargetSelectionPageState()

    var nextEnabled: Bool = false
    var isGoingBack: Bool = false
    var inputValidated: TargetSelectionInputValidation = .empty
    var sourceAccount: BlockchainAccount?
    var availableTargets: [TransactionTarget] = []
    var destination: TransactionTarget? {
        didSet {
            Logger.shared.debug("!TRANSACTION!>: destination \(String(describing: destination))")
        }
    }

    var step: TargetSelectionPageStep = .initial {
        didSet {
            isGoingBack = false
        }
    }

    static func == (lhs: TargetSelectionPageState, rhs: TargetSelectionPageState) -> Bool {
        lhs.nextEnabled == rhs.nextEnabled &&
            lhs.destination?.label == rhs.destination?.label &&
            lhs.sourceAccount?.identifier == rhs.sourceAccount?.identifier &&
            lhs.step == rhs.step &&
            lhs.inputValidated == rhs.inputValidated &&
            lhs.isGoingBack == rhs.isGoingBack &&
            lhs.availableTargets.map(\.label) == rhs.availableTargets.map(\.label)
    }
}
