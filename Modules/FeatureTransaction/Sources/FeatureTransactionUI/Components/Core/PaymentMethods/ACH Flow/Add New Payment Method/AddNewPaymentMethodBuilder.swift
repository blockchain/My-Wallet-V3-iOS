// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs

// MARK: - Builder

public protocol AddNewPaymentMethodBuildable {
    func build(
        listener: AddNewPaymentMethodListener,
        filter: @escaping (PaymentMethodType) -> Bool
    ) -> AddNewPaymentMethodRouting
}

extension AddNewPaymentMethodBuildable {

    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting {
        build(listener: listener, filter: { _ in true })
    }
}

public final class AddNewPaymentMethodBuilder: AddNewPaymentMethodBuildable {

    private let paymentMethodService: SelectPaymentMethodService

    public init(paymentMethodService: SelectPaymentMethodService) {
        self.paymentMethodService = paymentMethodService
    }

    public func build(
        listener: AddNewPaymentMethodListener,
        filter: @escaping (PaymentMethodType) -> Bool
    ) -> AddNewPaymentMethodRouting {
        let viewController = AddNewPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = AddNewPaymentMethodInteractor(
            presenter: viewController,
            paymentMethodService: paymentMethodService,
            filter: filter
        )
        interactor.listener = listener
        return AddNewPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
