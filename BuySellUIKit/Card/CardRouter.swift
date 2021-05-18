//
//  CardRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxRelay
import RxSwift
import ToolKit

public final class CardRouter: RIBs.Router<CardRouterInteractor> {
    
    // MARK: - Types

    // MARK: - Private Properties

    private let routingType: RoutingType
    private let navigationRouter: NavigationRouterAPI
    
    private let disposeBag = DisposeBag()
    private let internalInteractor: CardRouterInteractor
    private let builder: CardComponentBuilderAPI
    
    public init(interactor: CardRouterInteractor,
                builder: CardComponentBuilderAPI,
                routingType: RoutingType = .modal,
                navigationRouter: NavigationRouterAPI = NavigationRouter()) {
        self.builder = builder
        self.internalInteractor = interactor
        self.navigationRouter = navigationRouter
        self.routingType = routingType
        super.init(interactor: interactor)
    }
    
    // MARK: - Lifecycle
    
    public override func didLoad() {
        super.didLoad()
        
        // Embed the entire flow in another navigation controller
        // instead of generating one of its own
        if case .embed(inside: let navigationController) = routingType {
            navigationRouter.navigationControllerAPI = navigationController
        }
        
        // Action is a steam of events derived from a pblish relay
        interactor.action
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous(from: let state):
                    self.previous(from: state)
                case .next(to: let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        
        /// TODO: Remove once BuySell moves into RIBs because Should be automatically
        /// called by `Router` once `self` is attached as a child router.
        interactor.activate()
        
        // Once the interator becomes inactive dismiss the flow
        interactor.isActiveStream
            .filter { !$0 }
            .mapToVoid()
            .take(1)
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.navigationRouter.dismiss(completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - State Routing
    
    private func previous(from state: CardRouterInteractor.State) {
        switch state {
        case .cardDetails:
            interactor.deactivate()
        case .authorization, .billingAddress, .completed, .inactive, .pendingCardState:
            navigationRouter.pop(animated: true)
        }
    }
        
    private func next(to state: CardRouterInteractor.State) {
        switch state {
        case .cardDetails:
            showCardDetailsScreen()
        case .billingAddress(let cardData):
            showBillingAddressScreen(for: cardData)
        case .authorization(let data):
            showAuthorizationScreen(for: data)
        case .pendingCardState(cardId: let cardId):
            showPendingCardStateScreen(for: cardId)
        case .completed, .inactive:
            interactor.deactivate()
        }
    }
    
    // MARK: - Accessors
    
    private func showPendingCardStateScreen(for cardId: String) {
        let viewController = builder.pendingCardStatus(cardId: cardId)
        navigationRouter.present(viewController: viewController)
    }
    
    private func showAuthorizationScreen(for data: PartnerAuthorizationData) {
        let viewController = builder.cardAuthorization(for: data)
        navigationRouter.present(viewController: viewController)
    }
    
    private func showCardDetailsScreen() {
        let viewController = builder.cardDetails()
        viewController.isModalInPresentation = true
        navigationRouter.present(viewController: viewController)
    }
    
    private func showBillingAddressScreen(for cardData: CardData) {
        let viewController = builder.billingAddress(for: cardData, navigationControllerAPI: navigationRouter.navigationControllerAPI!)
        navigationRouter.present(viewController: viewController)
    }
}
