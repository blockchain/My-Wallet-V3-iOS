// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

enum PaymentMethodAction {
    case items([PaymentMethodCellSectionModel])
}

enum PaymentMethodEffects {
    case closeFlow
    case navigate(method: PaymentMethod)
}

protocol PaymentMethodRouting: ViewableRouting {}

protocol PaymentMethodPresentable: Presentable {
    func connect(action: Driver<PaymentMethodAction>) -> Driver<PaymentMethodEffects>
}

protocol PaymentMethodListener: AnyObject {
    /// Close the payment method screen
    func closePaymentMethodScreen()

    /// Routes to the `Linked Banks` screen
    func routeToLinkedBanks()

    /// Routes to the `Add [FiatCurrency] Wire Transfer` screen
    func routeToWireTransfer()
}

final class PaymentMethodInteractor: PresentableInteractor<PaymentMethodPresentable>, PaymentMethodInteractable {

    weak var router: PaymentMethodRouting?
    weak var listener: PaymentMethodListener?

    // MARK: - Private Properties

    private var paymentMethodTypes: Single<[PaymentMethodType]> {
        fiatCurrencyService
            .tradingCurrency
            .asSingle()
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<[PaymentMethodType]> in
                self.linkedBanksFactory.bankPaymentMethods(for: fiatCurrency).asSingle()
            }
    }

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let selectionRelay = PublishRelay<(method: PaymentMethod, methodType: PaymentMethodType)>()

    init(
        presenter: PaymentMethodPresentable,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.linkedBanksFactory = linkedBanksFactory
        self.fiatCurrencyService = fiatCurrencyService
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let methods = paymentMethodTypes
            .map { [weak self] (methods: [PaymentMethodType]) -> [PaymentMethodCellViewModelItem] in
                guard let self else { return [] }
                return methods.compactMap { type in
                    self.generateCellType(by: type) ?? nil
                }
            }
            .map { [PaymentMethodCellSectionModel(items: $0)] }
            .map { PaymentMethodAction.items($0) }
            .asDriver(onErrorDriveWith: .empty())

        let selectedPaymentMethod = selectionRelay
            .share(replay: 1, scope: .whileConnected)

        selectedPaymentMethod
            .map(\.method)
            .map(PaymentMethodEffects.navigate(method:))
            .asDriverCatchError()
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: methods)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handle(effect: PaymentMethodEffects) {
        switch effect {
        case .closeFlow:
            listener?.closePaymentMethodScreen()
        case .navigate(let method):
            switch method.type {
            case .bankAccount:
                listener?.routeToWireTransfer()
            case .bankTransfer:
                listener?.routeToLinkedBanks()
            case .card,
                 .funds,
                 .applePay:
                unimplemented()
            }
        }
    }

    private func generateCellType(by paymentMethodType: PaymentMethodType) -> PaymentMethodCellViewModelItem? {
        var cellType: PaymentMethodCellViewModelItem?
        switch paymentMethodType {
        case .suggested(let method):
            let viewModel: ExplainedActionViewModel
            switch method.type {
            case .funds:
                unimplemented()
            case .card:
                unimplemented()
            case .applePay:
                unimplemented()
            case .bankTransfer:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "icon-bank",
                    // TODO: Localization
                    title: "Link a Bank",
                    descriptions: [
                        // TODO: Localization
                        .init(title: "Instantly Available", titleColor: .semantic.body, titleFontSize: 14),
                        // TODO: Localization
                        .init(title: "Securely link a bank and send cash to your Blockchain.com Wallet at anytime.", titleColor: .descriptionText, titleFontSize: 12)
                    ],
                    badgeTitle: "Most Popular",
                    uniqueAccessibilityIdentifier: ""
                )
            case .bankAccount:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "icon-deposit-cash",
                    // TODO: Localization
                    title: "Wire Transfer",
                    descriptions: [
                        // TODO: Localization
                        .init(title: "3-5 Business Days", titleColor: .semantic.body, titleFontSize: 14),
                        // TODO: Localization
                        .init(title: "Send funds directly from your bank account to your Blockchain.com Wallet. Bank fees may apply.", titleColor: .descriptionText, titleFontSize: 12)
                    ],
                    badgeTitle: nil,
                    uniqueAccessibilityIdentifier: ""
                )
            }
            viewModel.tap
                // TODO: Analytics
                .map { _ in (method, paymentMethodType) }
                .emit(to: selectionRelay)
                .disposeOnDeactivate(interactor: self)

            cellType = .suggestedPaymentMethod(viewModel)
        case .card,
             .account,
             .linkedBank,
             .applePay:
            cellType = nil
        }
        return cellType
    }
}
