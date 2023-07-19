// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import RxCocoa
import RxSwift

protocol LinkBankFailureScreenRouting: ViewableRouting {}

protocol LinkBankFailureScreenPresentable: Presentable {}

protocol LinkBankFailureScreenListener: AnyObject {
    var retryAction: PublishRelay<LinkBankFlow.Action> { get }

    func closeFlow(isInteractive: Bool)
}

final class LinkBankFailureScreenInteractor: Interactor, LinkBankFailureScreenInteractable {

    weak var router: LinkBankFailureScreenRouting?
    weak var listener: LinkBankFailureScreenListener?

    let continueTapped = PublishRelay<Void>()
    let cancelTapped = PublishRelay<Void>()

    override func didBecomeActive() {
        super.didBecomeActive()

        continueTapped
            .subscribe(onNext: { [listener] _ in
                listener?.retryAction.accept(.retry)
            })
            .disposeOnDeactivate(interactor: self)

        cancelTapped
            .subscribe(onNext: { [listener] _ in
                listener?.closeFlow(isInteractive: false)
            })
            .disposeOnDeactivate(interactor: self)
    }
}
