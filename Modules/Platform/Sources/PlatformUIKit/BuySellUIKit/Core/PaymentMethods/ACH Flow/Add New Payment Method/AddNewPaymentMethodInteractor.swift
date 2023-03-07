// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

enum AddNewPaymentMethodAction {
    case items([AddNewPaymentMethodCellSectionModel])
}

enum AddNewPaymentMethodEffects {
    case closeFlow
    case navigate(method: PaymentMethod)
}

public protocol AddNewPaymentMethodRouting: ViewableRouting {}

protocol AddNewPaymentMethodPresentable: Presentable {
    func connect(action: Driver<AddNewPaymentMethodAction>) -> Driver<AddNewPaymentMethodEffects>
}

public protocol AddNewPaymentMethodListener: AnyObject {
    func closeFlow()
    func navigate(with method: PaymentMethod)
}

final class AddNewPaymentMethodInteractor: PresentableInteractor<AddNewPaymentMethodPresentable>,
    AddNewPaymentMethodInteractable
{

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias AnalyticsPaymentMethod = AnalyticsEvents.SimpleBuy.PaymentMethod
    private typealias NewAnalyticsEvent = AnalyticsEvents.New.SimpleBuy
    private typealias TrackEvent = (AnalyticsPaymentMethod) -> Void
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.AddPaymentMethodSelectionScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.PaymentMethodsScreen

    // MARK: - Injected

    weak var router: AddNewPaymentMethodRouting?
    weak var listener: AddNewPaymentMethodListener?

    private let paymentMethodService: SelectPaymentMethodService
    private let eventRecorder: AnalyticsEventRecorderAPI
    private let filter: (PaymentMethodType) -> Bool

    private let selectionRelay = PublishRelay<(method: PaymentMethod, methodType: PaymentMethodType)>()

    init(
        presenter: AddNewPaymentMethodPresentable,
        paymentMethodService: SelectPaymentMethodService,
        eventRecorder: AnalyticsEventRecorderAPI = resolve(),
        filter: @escaping (PaymentMethodType) -> Bool
    ) {
        self.paymentMethodService = paymentMethodService
        self.eventRecorder = eventRecorder
        self.filter = filter
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let methods = paymentMethodService
            .suggestedMethods
            .map { suggestedMethods in
                // The payment method of type `funds` needs to be at
                // the bottom of the list of payment methods as the
                // cell used to display the this type of payment method
                // is styled differently than the others.
                let fundsPaymentMethod = suggestedMethods
                    .first(where: { paymentMethodType in
                        if case .suggested(let method) = paymentMethodType {
                            return method.type.isFunds
                        } else {
                            return false
                        }
                    })
                let paymentMethods = suggestedMethods
                    .filter { paymentMethodType in
                        if case .suggested(let method) = paymentMethodType {
                            return !method.type.isFunds
                        } else {
                            return true
                        }
                    }

                // Card should be at the top of the list.
                let sorted = paymentMethods.sorted { lhs, _ in
                    if case .suggested(let method) = lhs {
                        return method.type.isCard
                    } else {
                        return false
                    }
                }

                // If there's a payment method of type `funds` we append
                // this to the sorted list. If not, we just return the sorted list.
                return fundsPaymentMethod == nil ? sorted : sorted + [fundsPaymentMethod!]
            }
            .map { [weak self] (methods: [PaymentMethodType]) -> [AddNewPaymentMethodCellViewModelItem] in
                guard let self else { return [] }
                return methods.compactMap { type in
                    if self.filter(type) {
                        return self.generateCellType(by: type) ?? nil
                    } else {
                        return nil
                    }
                }
            }
            .map { [AddNewPaymentMethodCellSectionModel(items: $0)] }
            .map { AddNewPaymentMethodAction.items($0) }
            .asDriver(onErrorDriveWith: .empty())

        let selectedPaymentMethod = selectionRelay
            .share(replay: 1, scope: .whileConnected)

        selectedPaymentMethod
            .map(\.methodType)
            .filter { paymentMethod in
                if case .funds(.fiat) = paymentMethod.method {
                    return false
                }
                return true
            }
            .subscribe(onNext: { [weak self] method in
                self?.paymentMethodService.select(method: method)
            })
            .disposeOnDeactivate(interactor: self)

        selectedPaymentMethod
            .map(\.method)
            .map(AddNewPaymentMethodEffects.navigate(method:))
            .asDriverCatchError()
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: methods)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handle(effect: AddNewPaymentMethodEffects) {
        switch effect {
        case .closeFlow:
            listener?.closeFlow()
        case .navigate(let method):
            listener?.navigate(with: method)
        }
    }

    private func generateCellType(
        by paymentMethodType: PaymentMethodType
    ) -> AddNewPaymentMethodCellViewModelItem? {
        var cellType: AddNewPaymentMethodCellViewModelItem?
        switch paymentMethodType {
        case .suggested(let method):
            let track: TrackEvent = { [eventRecorder] (event: AnalyticsPaymentMethod) in
                eventRecorder.record(
                    events: [
                        AnalyticsEvent.sbPaymentMethodSelected(selection: event),
                        NewAnalyticsEvent.buyPaymentMethodSelected(
                            paymentType: NewAnalyticsEvent.PaymentType(paymentMethod: method)
                        )
                    ]
                )
            }

            switch method.type {
            case .funds:
                let title = paymentMethodType.currency == .fiat(.USD)
                    || paymentMethodType.currency == .fiat(.ARS)
                    || paymentMethodType.currency == .fiat(.BRL)
                    ? LocalizedString.DepositCash.usTitle
                    : LocalizedString.DepositCash.europeTitle
                let paymentMethodTypeView = PaymentMethodTypeView(
                    title: title,
                    subtitle: LocalizedString.DepositCash.subtitle,
                    message: LocalizedString.DepositCash.description,
                    accessibilityIdentifier: AccessibilityId.bankTransfer,
                    onViewTapped: { [selectionRelay] in
                        track(.funds)
                        selectionRelay.accept(
                            (method: method, methodType: paymentMethodType)
                        )
                    }
                )
                cellType = .paymentMethodTypeView(paymentMethodTypeView)
            case .applePay:
                let viewModel = createApplePayExplainedActionViewModel()
                    .capabilities(method.capabilities)
                viewModel.tap
                    .do { _ in
                        track(.applePay)
                    }
                    .map { _ in (method, paymentMethodType) }
                    .emit(to: selectionRelay)
                    .disposeOnDeactivate(interactor: self)

                cellType = .suggestedPaymentMethod(viewModel)
            case .card:
                let viewModel = createCardExplainedActionViewModel()
                    .capabilities(method.capabilities)
                viewModel.tap
                    .do { _ in
                        track(.card)
                    }
                    .map { _ in (method, paymentMethodType) }
                    .emit(to: selectionRelay)
                    .disposeOnDeactivate(interactor: self)

                cellType = .suggestedPaymentMethod(viewModel)
            case .bankTransfer:
                let viewModel = createBankTransferExplainedActionViewModel()
                    .capabilities(method.capabilities)

                viewModel.tap
                    .do { _ in
                        track(.bank)
                    }
                    .map { _ in (method, paymentMethodType) }
                    .emit(to: selectionRelay)
                    .disposeOnDeactivate(interactor: self)
                cellType = .suggestedPaymentMethod(viewModel)
            case .bankAccount:
                fatalError("Bank account is not a valid payment method any longer")
            }
        case .card,
             .account,
             .applePay,
             .linkedBank:
            fatalError("Unsupported payment method type.")
        }
        return cellType
    }

    private func createBankTransferExplainedActionViewModel() -> ExplainedActionViewModel {
        ExplainedActionViewModel(
            thumbImage: "icon-bank",
            title: LocalizedString.LinkABank.title,
            descriptions: [
                .init(
                    title: LocalizedString.LinkABank.descriptionLimit,
                    titleColor: .titleText,
                    titleFontSize: 14
                ),
                .init(
                    title: LocalizedString.LinkABank.descriptionInfo,
                    titleColor: .descriptionText,
                    titleFontSize: 12
                )
            ],
            badgeTitle: nil,
            uniqueAccessibilityIdentifier: AccessibilityId.linkedBank
        )
    }

    private func createCardExplainedActionViewModel() -> ExplainedActionViewModel {
        ExplainedActionViewModel(
            thumbImage: "Icon-Creditcard",
            title: LocalizedString.Card.title,
            descriptions: [
                .init(
                    title: LocalizedString.Card.descriptionLimit,
                    titleColor: .titleText,
                    titleFontSize: 14
                ),
                .init(
                    title: LocalizedString.Card.descriptionInfo,
                    titleColor: .descriptionText,
                    titleFontSize: 12
                )
            ],
            badgeTitle: nil,
            uniqueAccessibilityIdentifier: AccessibilityId.addCard
        )
    }

    private func createApplePayExplainedActionViewModel() -> ExplainedActionViewModel {
        ExplainedActionViewModel(
            thumbImage: "icon-applepay",
            title: LocalizedString.ApplePay.title,
            descriptions: [
                .init(
                    title: LocalizedString.ApplePay.descriptionLimit,
                    titleColor: .titleText,
                    titleFontSize: 14
                ),
                .init(
                    title: LocalizedString.ApplePay.descriptionInfo,
                    titleColor: .descriptionText,
                    titleFontSize: 12
                )
            ],
            badgeTitle: LocalizedString.Card.badgeTitle,
            uniqueAccessibilityIdentifier: AccessibilityId.useApplePay,
            thumbRenderDefault: true
        )
    }
}
