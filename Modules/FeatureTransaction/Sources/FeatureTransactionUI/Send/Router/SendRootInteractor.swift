// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol SendRootInteractable: Interactable, TransactionFlowListener {
    var router: SendRootRouting? { get set }
    var listener: SendRootListener? { get set }
}

public protocol SendRootListener: ViewListener {}

public final class SendRootInteractor: Interactor, SendRootInteractable, SendRootListener {

    weak var router: SendRootRouting?
    weak var listener: SendRootListener?

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        super.init()
    }

    public func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        unimplemented()
    }

    public func dismissTransactionFlow() {
        router?.dismissTransactionFlow()
    }
}
