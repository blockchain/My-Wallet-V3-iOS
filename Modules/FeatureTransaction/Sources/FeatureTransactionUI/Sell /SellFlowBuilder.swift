// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol SellFlowBuildable: Buildable {
    func build(with listener: SellFlowListening, interactor: SellFlowInteractor) -> SellFlowRouting
}

final class SellFlowBuilder: SellFlowBuildable {

    func build(with listener: SellFlowListening, interactor: SellFlowInteractor) -> SellFlowRouting {
        let router = SellFlowRouter(interactor: interactor)
        interactor.listener = listener
        interactor.router = router
        return router
    }
}
