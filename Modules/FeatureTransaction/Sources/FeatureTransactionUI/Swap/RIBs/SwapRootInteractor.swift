// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit
import UIKit

public final class SwapRootInteractor: Interactor, TransactionFlowListener {

    override public init() {}

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    public func dismissTransactionFlow() { }
}
