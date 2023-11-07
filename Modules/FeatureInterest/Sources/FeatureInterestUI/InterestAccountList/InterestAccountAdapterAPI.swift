// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import UIKit

/// Represents the possible outcomes when presenting and interacting
/// with the `InterestAccountList`
enum InterestAccountOverviewAction: Equatable {
    case closed
    case selected(BlockchainAccount)
}

extension InterestAccountOverviewAction {
    static func == (
        lhs: InterestAccountOverviewAction,
        rhs: InterestAccountOverviewAction
    ) -> Bool {
        switch (lhs, rhs) {
        case (.closed, .closed):
            true
        case (.selected(let left), .selected(let right)):
            left.identifier == right.identifier
        default:
            false
        }
    }
}

protocol InterestAccountAdapterAPI {
    func presentInterestOverviewScreenFromViewController(
        _ viewController: UIViewController,
        completion: @escaping (InterestAccountOverviewAction) -> Void
    )

    func presentInterestOverviewScreenFromViewController(
        _ viewController: UIViewController
    ) -> AnyPublisher<InterestAccountOverviewAction, Never>
}
