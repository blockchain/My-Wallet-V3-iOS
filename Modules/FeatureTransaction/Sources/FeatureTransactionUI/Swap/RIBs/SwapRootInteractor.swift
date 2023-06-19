// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit
import UIKit

public final class SwapRootInteractor: Interactor, TransactionFlowListener {
    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()

    override public init() {}

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    deinit {
        subject.send(completion: .finished)
    }

    public func dismissTransactionFlow() {
        subject.send(.abandoned)
    }
}
