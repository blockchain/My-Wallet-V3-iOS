// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

protocol ConfirmationPagePresentable: Presentable {
    var continueButtonTapped: Signal<Void> { get }
    var memoFieldStateIsInvalid: Signal<Bool> { get }

    func connect(action: Driver<ConfirmationPageInteractor.Action>) -> Driver<ConfirmationPageInteractor.Effects>
}

final class ConfirmationPageDetailsPresenter: DetailsScreenPresenterAPI, ConfirmationPagePresentable {
    // MARK: - Navigation Properties

    let reloadRelay = PublishRelay<Void>()
    let titleViewRelay = BehaviorRelay<Screen.Style.TitleView>(value: .none)
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        contentReducer.navigationBarAppearance
    }

    // MARK: - Actions

    var continueButtonTapped: Signal<Void> {
        contentReducer
            .continueButtonViewModel
            .tap
    }

    var memoFieldStateIsInvalid: Signal<Bool> {
        contentReducer
            .memoModel
            .state
            .map { state in
                state.isInvalid
            }
            .asSignal(onErrorJustReturn: false)
    }

    // MARK: - Screen Properties

    var buttons: [ButtonViewModel] {
        contentReducer.buttons
    }

    var disclaimers: [DisclaimerViewModel] {
        contentReducer.disclaimers
    }

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    func header(for section: Int) -> HeaderBuilder? {
        contentReducer.header
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let navigationCloseRelay = PublishRelay<Void>()
    private let backButtonPressed = PublishRelay<Void>()
    private let continueButtonPressed = PublishRelay<Void>()

    private let contentReducer = ConfirmationPageContentReducer()

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder

        self.navigationBarTrailingButtonAction = .default
        self.navigationBarLeadingButtonAction = .custom { [backButtonPressed] in
            backButtonPressed.accept(())
        }
    }

    func connect(action: Driver<ConfirmationPageInteractor.Action>) -> Driver<ConfirmationPageInteractor.Effects> {
        let details = action
            .distinctUntilChanged()
            .flatMap { action -> Driver<TransactionState> in
                switch action {
                case .empty:
                    return .empty()
                case .load(let data):
                    return .just(data)
                }
            }

        Driver.combineLatest(details.map(\.nextEnabled), details.map(\.termsAndAgreementsAreValid))
            .map { $0 && $1 }
            .drive(contentReducer.continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        details
            .drive(weak: self) { (self, state) in
                self.setup(state: state)
            }
            .disposed(by: disposeBag)

        let cancelTapped = contentReducer
            .cancelButtonViewModel
            .tap
            .withLatestFrom(details)
            .map { details -> ConfirmationPageInteractor.Effects in
                details.stepsBackStack.isEmpty ?
                    .close
                    : .back
            }
            .asDriverCatchError()

        let backTapped = backButtonPressed
            .map { ConfirmationPageInteractor.Effects.back }
            .asDriverCatchError()

        let termsChanged = contentReducer
            .termsUpdated
            .distinctUntilChanged()
            .map { value -> ConfirmationPageInteractor.Effects in
                .toggleTermsOfServiceAgreement(value)
            }
            .asDriverCatchError()

        let hyperlinkTapped = contentReducer
            .hyperlinkTapped
            .map { value -> ConfirmationPageInteractor.Effects in
                .tappedHyperlink(value)
            }
            .asDriverCatchError()

        let transferAgreementChanged = contentReducer
            .transferAgreementUpdated
            .distinctUntilChanged()
            .map { value -> ConfirmationPageInteractor.Effects in
                .toggleHoldPeriodAgreement(value)
            }
            .asDriverCatchError()

        let memoChanged = contentReducer
            .memoUpdated
            .distinctUntilChanged(\.0)
            .map { text, oldModel -> ConfirmationPageInteractor.Effects in
                .updateMemo(text, oldModel: oldModel)
            }
            .asDriverCatchError()

        let continueButtonTapped = continueButtonTapped
            .map { [memoModel = contentReducer.memoModel] _ -> ConfirmationPageInteractor.Effects in
                // we need to make sure that memo is updated when continue button is tapped
                memoModel.focusRelay.accept(.off(.endEditing))
                return .none
            }
            .asDriverCatchError()

        let showACHDepositTermsTapped = contentReducer
            .showACHDepositTermsTapped
            .map { value -> ConfirmationPageInteractor.Effects in
                    .showACHDepositTerms(termsDescription: value)
            }
            .asDriverCatchError()

        let availableToWithdrawDateInfoTapped = contentReducer
            .availableToWithdrawDateInfoTapped
            .map { _ -> ConfirmationPageInteractor.Effects in
                    .showAvailableToWithdrawDateInfo
            }
            .asDriverCatchError()

        return .merge(
            cancelTapped,
            backTapped,
            continueButtonTapped,
            memoChanged,
            transferAgreementChanged,
            termsChanged,
            hyperlinkTapped,
            showACHDepositTermsTapped,
            availableToWithdrawDateInfoTapped
        )
    }

    private func setup(state: TransactionState) {
        contentReducer.setup(for: state)
        titleViewRelay.accept(.text(value: contentReducer.title))
        reloadRelay.accept(())
    }
}
