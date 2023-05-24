// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import Foundation
import MoneyKit
import PlatformKit
import RIBs
import ToolKit
import UIKit

public final class SellFlowInteractor: Interactor {

    enum Error: Swift.Error {
        case noCustodialAccountFound(CryptoCurrency)
        case other(Swift.Error)
    }

    public var listener: SellFlowListening?
    weak var router: SellFlowRouting?
}

extension SellFlowInteractor: TransactionFlowListener {

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        listener?.presentKYCFlow(from: viewController, completion: completion)
    }

    public func dismissTransactionFlow() {
        listener?.sellFlowDidComplete(with: .abandoned)
    }
}
