// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit
import UIKit

public final class BuyFlowInteractor: Interactor {

    public var listener: BuyFlowListening?
    weak var router: BuyFlowRouting?
}

extension BuyFlowInteractor: TransactionFlowListener {

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        listener?.presentKYCFlow(from: viewController, completion: completion)
    }

    public func dismissTransactionFlow() {
        listener?.buyFlowDidComplete(with: .abandoned)
    }
}
