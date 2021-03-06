// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

final class PendingOrderStateScreenPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.PendingOrderScreen

    // MARK: - Properties

    var viewModel: Driver<PendingStateViewModel> {
        viewModelRelay
            .asDriver()
            .compactMap { $0 }
    }

    private let viewModelRelay = BehaviorRelay<PendingStateViewModel?>(value: nil)
    private let routingInteractor: PendingOrderRoutingInteracting
    private let interactor: PendingOrderStateScreenInteractor
    private let analyticsRecorder: AnalyticsEventRecording
    private let tabSwapping: TabSwapping
    private let topMostViewControllerProviding: TopMostViewControllerProviding
    private let disposeBag = DisposeBag()

    private var amount: String {
        interactor.amount.toDisplayString(includeSymbol: true)
    }

    private var currencyType: CurrencyType {
        interactor.amount.currencyType
    }

    // MARK: - Setup

    init(routingInteractor: PendingOrderRoutingInteracting,
         interactor: PendingOrderStateScreenInteractor,
         topMostViewControllerProviding: TopMostViewControllerProviding = resolve(),
         tabSwapping: TabSwapping = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve()) {
        self.topMostViewControllerProviding = topMostViewControllerProviding
        self.tabSwapping = tabSwapping
        self.analyticsRecorder = analyticsRecorder
        self.routingInteractor = routingInteractor
        self.interactor = interactor
        super.init(interactable: interactor)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        let isBuy = interactor.isBuy
        let prefix = isBuy ? LocalizedString.Loading.Buy.titlePrefix : LocalizedString.Loading.Sell.titlePrefix
        let subtitle = isBuy ? LocalizedString.Loading.Buy.subtitle : LocalizedString.Loading.Sell.subtitle
        let localImage = currencyType.logoResource.local
        viewModelRelay.accept(
            PendingStateViewModel(
                compositeStatusViewType: .composite(
                    .init(
                        baseViewType: .image(localImage.name, localImage.bundle),
                        sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter)
                    )
                ),
                title: "\(prefix) \(amount)",
                subtitle: subtitle
            )
        )

        viewModelRelay
            .asObservable()
            .compactMap { $0 }
            .flatMap(\.tap)
            .bindAndCatch(to: routingInteractor.tapRelay)
            .disposed(by: disposeBag)

        interactor.startPolling()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] state in
                    self?.handle(state: state)
                },
                onError: { [weak self] error in
                    /// In the event of an `RxError` we don't have a completion
                    /// state that indicates success or failure. Sometimes we get an
                    /// RxError of type `.noElements`. So far, in all instances of this
                    /// the order has gone to `inProgress`.
                    /// In the event that this happens, we show the error as a timeout error
                    /// and route the user to `Activity` if they tap the `View Activity`
                    /// button.
                    if let _ = error as? RxError {
                        self?.showRxFailureError(isBuy: isBuy)
                    } else {
                        self?.showError(localizedDescription: String(describing: error))
                    }
                }
            )
            .disposed(by: disposeBag)
    }

    /// This is different from the other timeout screen.
    /// This is only called when Rx throws an error which
    /// we cannot gracefully handle. We tell the user their order
    /// has been submitted and to check `Activity`.
    private func showRxFailureError(isBuy: Bool) {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        let supplementary = ButtonViewModel.secondary(with: LocalizationConstants.TimeoutScreen.supplementaryButton)

        supplementary
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.routeToActivity()
            }
            .disposed(by: disposeBag)

        button
            .tapRelay
            .map { .completed }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)

        let title = isBuy ? LocalizationConstants.TimeoutScreen.Buy.title : LocalizationConstants.TimeoutScreen.Sell.title
        let logoResource = currencyType.logoResource.local
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(logoResource.name, logoResource.bundle),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.clock.name), position: .radiusDistanceFromCenter)
                )
            ),
            title: title,
            subtitle: LocalizationConstants.TimeoutScreen.subtitle,
            button: button,
            supplementaryButton: supplementary
        )
        viewModelRelay.accept(viewModel)
    }

    private func showError(localizedDescription: String) {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .completed }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)

        let localImage = currencyType.logoResource.local
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(localImage.name, localImage.bundle),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.circleError.name), position: .radiusDistanceFromCenter)
                )
            ),
            title: LocalizationConstants.ErrorScreen.title,
            subtitle: "\(LocalizationConstants.ErrorScreen.subtitle) \n\(localizedDescription)",
            button: button
        )
        viewModelRelay.accept(viewModel)
    }

    private func handleTimeout(order: OrderDetails) {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .pending(order) }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)
        var title = ""
        var subtitle = LocalizedString.Timeout.subtitle
        if order.isBuy {
            switch order.paymentMethod {
            case .bankTransfer:
                title = LocalizedString.Timeout.Buy.achTitleSuffix
                subtitle = String(format: LocalizedString.Timeout.achSubtitle, getEstimateTransactionCompletionTime())
            case .bankAccount, .card, .funds:
                title = LocalizedString.Timeout.Buy.titleSuffix
            }
        } else {
            title = LocalizedString.Timeout.Sell.titleSuffix
        }

        let localImage = currencyType.logoResource.local
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(localImage.name, localImage.bundle),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.clock.name), position: .radiusDistanceFromCenter)
                )
            ),
            title: "\(amount) \(title)",
            subtitle: subtitle,
            button: button,
            displayCloseButton: true
        )
        viewModelRelay.accept(viewModel)
    }

    private func handleSuccess() {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .completed }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)
        let suffix = interactor.isBuy ? LocalizedString.Success.Buy.titleSuffix : LocalizedString.Success.Sell.titleSuffix
        let name = interactor.isBuy ? currencyType.name : LocalizedString.Success.Sell.cash
        let buySubtitle = String(format: "\(LocalizedString.Success.Subtitle.Buy.subtitle)", interactor.inputCurrencyType.displayCode)
        // swiftlint:disable line_length
        let subtitle = interactor.isBuy ? buySubtitle : "\(LocalizedString.Success.Subtitle.prefix) \(name) \(LocalizedString.Success.Subtitle.suffix)"
        var interactibleText: String?
        var url: String?
        if interactor.isBuy {
            interactibleText = "\n\(LocalizedString.Success.Buy.learnMore)"
            url = "https://support.blockchain.com/hc/en-us/articles/360048200392"
        }
        let localImage = currencyType.logoResource.local
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(localImage.name, localImage.bundle),
                    sideViewAttributes: .init(type: .image("v-success-icon"), position: .radiusDistanceFromCenter)
                )
            ),
            title: "\(amount) \(suffix)",
            subtitle: subtitle,
            interactibleText: interactibleText,
            url: url,
            button: button
        )
        self.viewModelRelay.accept(viewModel)
    }

    private func handle(state: PolledOrder) {
        switch state {
        case .final(let order):
            switch order.state {
            case .cancelled, .failed, .expired:
                analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .failure))
                /// There's no error here.
                showError(localizedDescription: "")
            case .finished:
                analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .success))
                handleSuccess()
            case .pendingConfirmation, .pendingDeposit, .depositMatched:
                // This state is practically not possible by design since the app polls until
                // the order is in one of the final states (success / error).
                routingInteractor.stateRelay.accept(.pending(order))
            }
        case .timeout(let order):
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .timeout))
            handleTimeout(order: order)
        case .cancel:
            break
        }
    }

    private func routeToActivity() {
        dismissTopMost(weak: self) { presenter in
            presenter.tabSwapping.switchToActivity()
        }
    }

    private func dismissTopMost(weak object: PendingOrderStateScreenPresenter, _ selector: @escaping (PendingOrderStateScreenPresenter) -> Void) {
            guard let viewController = topMostViewControllerProviding.topMostViewController else {
                selector(object)
                return
            }
            viewController.dismiss(animated: true, completion: {
                selector(object)
            })
        }

    private func getEstimateTransactionCompletionTime() -> String {
        guard let fiveDaysFromNow = Calendar.current.date(byAdding: .day, value: 5, to: Date()) else {
            return ""
        }
        return DateFormatter.medium.string(from: fiveDaysFromNow)
    }
}
