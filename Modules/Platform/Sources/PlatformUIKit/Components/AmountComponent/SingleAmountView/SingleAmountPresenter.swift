// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

/// NOTE: Currently this is only used in the `Withdraw` flow. If you
/// are using this outside of `Withdraw` you must create a `DisplayBundle`
/// type class that holds analytic events and localized strings.
public final class SingleAmountPresenter: AmountViewPresenting {

    // MARK: - Types

    public enum State {
        case empty
    }

    private typealias AccessibilityId = Accessibility.Identifier.Amount

    let amountPresenter: InputAmountLabelPresenter
    let auxiliaryButtonEnabledRelay = BehaviorRelay<Bool>(value: true)

    var auxiliaryButtonEnabled: Driver<Bool> {
        auxiliaryButtonEnabledRelay.asDriver()
    }

    let disponseBag = DisposeBag()

    // MARK: - Injected

    private let interactor: SingleAmountInteractor

    // MARK: - Accessors

    private let stateRelay = BehaviorRelay<State>(value: .empty)

    private let disposeBag = DisposeBag()

    public init(interactor: SingleAmountInteractor) {
        self.interactor = interactor

        self.amountPresenter = InputAmountLabelPresenter(
            interactor: interactor.currencyInteractor,
            currencyCodeSide: .leading
        )

        interactor.auxiliaryViewEnabledRelay
            .bindAndCatch(to: auxiliaryButtonEnabledRelay)
            .disposed(by: disposeBag)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        let input = input.filter { !$0.isEmpty }
        return interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> AmountPresenterState in
                guard let self else { return .validInput(nil) }
                return setupButton(by: state)
            }
    }

    // MARK: - Private

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

    internal var isEmpty: Bool {
        switch self {
        case .input(let value):
            return "\(value)".isEmpty
        case .delete:
            return false
        }
    }
}
