// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

extension Accessibility.Identifier {
    enum Amount {
        static let max = "Amount.useMaxButton"
        static let min = "Amount.useMinButton"
        static let warning = "Amount.warning"
        static let error = "Amount.error"
    }
}

public final class AmountTranslationPresenter: AmountViewPresenting {

    // MARK: - Types

    public struct DisplayBundle {
        public struct Events {
            public let minTappedAnalyticsEvent: AnalyticsEvent
            public let maxTappedAnalyticsEvent: AnalyticsEvent

            public init(min: AnalyticsEvent, max: AnalyticsEvent) {
                self.minTappedAnalyticsEvent = min
                self.maxTappedAnalyticsEvent = max
            }
        }

        public struct Strings {
            public let useMin: String
            public let useMax: String

            public init(useMin: String, useMax: String) {
                self.useMin = useMin
                self.useMax = useMax
            }
        }

        public struct AccessibilityIdentifiers {
            public init() {}
        }

        public let strings: Strings
        public let events: Events?
        public let accessibilityIdentifiers: AccessibilityIdentifiers

        public init(
            events: Events?,
            strings: Strings,
            accessibilityIdentifiers: AccessibilityIdentifiers
        ) {
            self.events = events
            self.strings = strings
            self.accessibilityIdentifiers = accessibilityIdentifiers
        }
    }

    public enum Input {
        case input(Character)
        case delete
    }

    private typealias AccessibilityId = Accessibility.Identifier.Amount

    // MARK: - Public Properties

    public let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    public let auxiliaryButtonEnabledRelay = BehaviorRelay<Bool>(value: true)

    // MARK: - Internal Properties

    var activeAmountInput: Driver<ActiveAmountInput> {
        interactor.activeInputRelay.asDriver()
    }

    var state: Driver<AmountPresenterState> {
        stateRelay.asDriver()
    }

    var swapButtonVisibility: Driver<Visibility> {
        swapButtonVisibilityRelay.asDriver()
    }

    let swapButtonTapRelay = PublishRelay<Void>()
    let auxiliaryButtonTappedRelay = PublishRelay<Void>()

    var auxiliaryButtonEnabled: Driver<Bool> {
        auxiliaryButtonEnabledRelay.asDriver()
    }

    var maxLimitPublisher: AnyPublisher<FiatValue, Never> {
        interactor.maxLimitPublisher
    }

    var lastPurchasePublisher: AnyPublisher<FiatValue, Never> {
        interactor.lastPurchasePublisher
    }

    // MARK: - Injected

    let interactor: AmountTranslationInteractor
    let fiatPresenter: InputAmountLabelPresenter
    let cryptoPresenter: InputAmountLabelPresenter
    let displayBundle: DisplayBundle

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let app: AppProtocol

    // MARK: - Accessors

    private let stateRelay = BehaviorRelay<AmountPresenterState>(value: .validInput(nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AmountTranslationInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        displayBundle: DisplayBundle,
        inputTypeToggleVisibility: Visibility,
        app: AppProtocol,
        maxLimitPublisher: AnyPublisher<FiatValue, Never> = .empty()
    ) {
        self.interactor = interactor
        self.analyticsRecorder = analyticsRecorder
        self.displayBundle = displayBundle
        self.app = app

        swapButtonVisibilityRelay.accept(inputTypeToggleVisibility)
        self.fiatPresenter = .init(interactor: interactor.fiatInteractor, currencyCodeSide: .leading)
        self.cryptoPresenter = .init(interactor: interactor.cryptoInteractor, currencyCodeSide: .trailing)

        swapButtonTapRelay
            .withLatestFrom(interactor.activeInput)
            .map(\.inverted)
            .do(
                onNext: { input in
                    app.post(
                        event: blockchain.ux.transaction.enter.amount.swap.input,
                        context: [
                            blockchain.ux.transaction.enter.amount.swap.input.crypto: input == .crypto,
                            blockchain.ux.transaction.enter.amount.swap.input.fiat: input == .fiat
                        ]
                    )
                }
            )
            .bindAndCatch(to: interactor.activeInputRelay)
            .disposed(by: disposeBag)

        auxiliaryButtonTappedRelay
            .bindAndCatch(to: interactor.auxiliaryButtonTappedRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                interactor.state,
                interactor.activeInput
            )
            .map(weak: self) { (self, payload) in
                self.setupButton(by: payload.0)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        interactor.auxiliaryViewEnabledRelay
            .bindAndCatch(to: auxiliaryButtonEnabledRelay)
            .disposed(by: disposeBag)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> AmountPresenterState in
                guard let self else { return .validInput(nil) }
                return setupButton(by: state)
            }
    }

    private func setupButton(by state: AmountInteractorState) -> AmountPresenterState {
        switch state {
        case .validInput(let messageState):
            return .validInput(buttonViewModel(state: messageState))
        case .invalidInput(let messageState):
            return .invalidInput(buttonViewModel(state: messageState))
        }
    }

    private func buttonViewModel(state: AmountInteractorState.MessageState) -> ButtonViewModel? {
        let viewModel: ButtonViewModel?
        switch state {
        case .none:
            return nil
        case .info(let message):
            viewModel = ButtonViewModel.info(with: message, accessibilityId: message)

        case .warning(let message):
            viewModel = ButtonViewModel.warning(with: message, accessibilityId: message)

        case .error(let message):
            viewModel = ButtonViewModel.error(with: message, accessibilityId: message)
        }

        viewModel?.tap
            .emit(
                onNext: { [interactor] in
                    interactor.auxiliaryButtonTappedRelay.accept(())
                }
            )
            .disposed(by: disposeBag)

        return viewModel
    }
}

extension AmountPresenterInput {
    internal var toInteractorInput: AmountInteractorInput {
        switch self {
        case .input(let value):
            return .insert(value)
        case .delete:
            return .remove
        }
    }
}
