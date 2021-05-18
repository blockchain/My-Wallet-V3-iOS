//
//  SelectPaymentMethodBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol SelectPaymentMethodBuildable {
    func build(listener: SelectPaymentMethodListener) -> SelectPaymentMethodRouting
}

final class SelectPaymentMethodBuilder: SelectPaymentMethodBuildable {

    private let stateService: StateServiceAPI
    private let paymentMethodService: SelectPaymentMethodService

    init(stateService: StateServiceAPI, paymentMethodService: SelectPaymentMethodService) {
        self.stateService = stateService
        self.paymentMethodService = paymentMethodService
    }

    func build(listener: SelectPaymentMethodListener) -> SelectPaymentMethodRouting {
        let viewController = SelectPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = SelectPaymentMethodInteractor(presenter: viewController,
                                                       paymentMethodService: paymentMethodService)
        interactor.listener = listener
        return SelectPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
