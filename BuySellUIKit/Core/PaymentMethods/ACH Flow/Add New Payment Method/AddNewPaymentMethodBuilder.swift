//
//  AddNewPaymentMethodBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol AddNewPaymentMethodBuildable {
    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting
}

final class AddNewPaymentMethodBuilder: AddNewPaymentMethodBuildable {

    private let stateService: StateServiceAPI
    private let paymentMethodService: SelectPaymentMethodService

    init(stateService: StateServiceAPI, paymentMethodService: SelectPaymentMethodService) {
        self.stateService = stateService
        self.paymentMethodService = paymentMethodService
    }

    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting {
        let viewController = AddNewPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = AddNewPaymentMethodInteractor(presenter: viewController,
                                                       paymentMethodService: paymentMethodService)
        interactor.listener = listener
        return AddNewPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
