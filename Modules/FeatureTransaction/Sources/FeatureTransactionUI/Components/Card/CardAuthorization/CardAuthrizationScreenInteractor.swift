// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

public final class CardAuthorizationScreenInteractor: Interactor {

    private let routingInteractor: CardAuthorizationRoutingInteractorAPI

    public init(routingInteractor: CardAuthorizationRoutingInteractorAPI) {
        self.routingInteractor = routingInteractor
    }

    public func cardAuthorized(with identifier: String) {
        routingInteractor.cardAuthorized(with: identifier)
    }
}
