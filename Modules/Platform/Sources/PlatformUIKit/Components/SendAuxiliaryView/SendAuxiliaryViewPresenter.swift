// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SendAuxiliaryViewPresenter {

    public struct State {
        let maxButtonVisibility: Visibility
        let networkFeeVisibility: Visibility
        let bitpayVisibility: Visibility
        let availableBalanceTitle: String
        let maxButtonTitle: String

        public init(
            maxButtonVisibility: Visibility,
            networkFeeVisibility: Visibility,
            bitpayVisibility: Visibility,
            availableBalanceTitle: String,
            maxButtonTitle: String
        ) {
            self.maxButtonVisibility = maxButtonVisibility
            self.networkFeeVisibility = networkFeeVisibility
            self.bitpayVisibility = bitpayVisibility
            self.availableBalanceTitle = availableBalanceTitle
            self.maxButtonTitle = maxButtonTitle
        }

        public static let initial: State = .init(
            maxButtonVisibility: .hidden,
            networkFeeVisibility: .hidden,
            bitpayVisibility: .hidden,
            availableBalanceTitle: LocalizationConstants.Transaction.available,
            maxButtonTitle: LocalizationConstants.Transaction.Swap.swapMax
        )
    }

    // MARK: - Types

    private typealias LocalizationId = LocalizationConstants.Transaction.Send

    // MARK: - Public Properties

    public private(set) lazy var state = stateRelay.asDriver()

    public let stateRelay: BehaviorRelay<State>

    // MARK: - Internal Properties

    let interactor: SendAuxiliaryViewInteractorAPI

    let maxButtonViewModel: ButtonViewModel

    let availableBalanceContentViewPresenter: ContentLabelViewPresenter

    let networkFeeContentViewPresenter: ContentLabelViewPresenter

    let imageContent: Driver<ImageViewContent>

    // MARK: - Private

    private let disposeBag = DisposeBag()

    // MARK: - Init

    public init(
        interactor: SendAuxiliaryViewInteractorAPI,
        initialState: State = .initial
    ) {

        // MARK: Setting up

        self.interactor = interactor
        self.stateRelay = .init(value: initialState)

        self.networkFeeContentViewPresenter = ContentLabelViewPresenter(
            title: LocalizationId.networkFee,
            alignment: .right,
            adjustsFontSizeToFitWidth: .true(factor: 0.60),
            interactor: interactor.networkFeeContentViewInteractor,
            accessibilityPrefix: "NetworkFee"
        )

        self.maxButtonViewModel = ButtonViewModel.secondary(
            with: initialState.maxButtonTitle,
            borderColor: .clear,
            font: .main(.semibold, 14)
        )

        self.availableBalanceContentViewPresenter = ContentLabelViewPresenter(
            title: initialState.availableBalanceTitle,
            alignment: .left,
            adjustsFontSizeToFitWidth: .true(factor: 0.60),
            interactor: interactor.availableBalanceContentViewInteractor,
            accessibilityPrefix: "AvailableBalance"
        )

        self.imageContent = interactor
            .imageRelay
            .asDriverCatchError()

        // MARK: Fee

        networkFeeContentViewPresenter.tap
            .emit(to: interactor.networkFeeTappedRelay)
            .disposed(by: disposeBag)

        // MARK: Max Button

        maxButtonViewModel.contentInsetRelay
            .accept(UIEdgeInsets(horizontal: Spacing.standard, vertical: 0))
        maxButtonViewModel.tap
            .emit(to: interactor.resetToMaxAmountRelay)
            .disposed(by: disposeBag)

        // MARK: Available Balance

        availableBalanceContentViewPresenter.containsDescription
            .drive(maxButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        availableBalanceContentViewPresenter.tap
            .emit(to: interactor.availableBalanceTappedRelay)
            .disposed(by: disposeBag)

        // MARK: State

        state
            .map(\.availableBalanceTitle)
            .drive(availableBalanceContentViewPresenter.titleRelay)
            .disposed(by: disposeBag)

        state
            .map(\.maxButtonTitle)
            .drive(maxButtonViewModel.textRelay)
            .disposed(by: disposeBag)

        state
            .map(\.maxButtonVisibility)
            .map(\.isHidden)
            .drive(maxButtonViewModel.isHiddenRelay)
            .disposed(by: disposeBag)
    }
}
