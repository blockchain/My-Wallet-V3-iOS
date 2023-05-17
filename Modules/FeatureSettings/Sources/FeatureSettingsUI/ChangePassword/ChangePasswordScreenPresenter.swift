// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class ChangePasswordScreenPresenter {

    // MARK: - Types

    private typealias InteractionInput = ChangePasswordScreenInteractor.InteractorInput
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.ChangePassword
    private typealias LocalizationIDs = LocalizationConstants.Settings.ChangePassword

    // MARK: - Exposed Properties

    let leadingButton: Screen.Style.LeadingButton = .back

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationIDs.title)
    }

    let barStyle = Screen.Style.Bar.darkContent()
    let descriptionContent: LabelContent
    let currentPasswordTextFieldViewModel: TextFieldViewModel
    let passwordTextFieldViewModel: PasswordTextFieldViewModel
    let confirmPasswordTextFieldViewModel: PasswordTextFieldViewModel
    let buttonViewModel = ButtonViewModel.primary(
        with: LocalizationIDs.action,
        accessibilityId: AccessibilityIDs.changePasswordButton
    )

    /// The total state of the presentation
    var state: Driver<FormPresentationState> {
        stateRelay.asDriver()
    }

    // MARK: - Injected Properties

    private let interactor: ChangePasswordScreenInteractor
    private let alertPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let coordinator: AuthenticationCoordinating

    // MARK: - Accessors

    private unowned let previousAPI: RoutingPreviousStateEmitterAPI
    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        alertPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        previousAPI: RoutingPreviousStateEmitterAPI,
        interactor: ChangePasswordScreenInteractor,
        coordinator: AuthenticationCoordinating = resolve()
    ) {
        self.previousAPI = previousAPI
        self.interactor = interactor
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        self.coordinator = coordinator

        self.descriptionContent = .init(
            text: LocalizationIDs.description,
            font: .main(.medium, 14.0),
            color: .semantic.body,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )

        let newPasswordValidator = TextValidationFactory.Password.new
        let confirmNewPasswordValidator = TextValidationFactory.Password.new

        let textMatchValidator = CollectionTextMatchValidator(
            newPasswordValidator,
            confirmNewPasswordValidator,
            invalidReason: LocalizationConstants.TextField.Gesture.passwordMismatch
        )

        self.currentPasswordTextFieldViewModel = TextFieldViewModel(
            with: .currentPassword,
            validator: TextValidationFactory.Password.login,
            messageRecorder: resolve()
        )

        self.passwordTextFieldViewModel = PasswordTextFieldViewModel(
            with: .newPassword,
            passwordValidator: newPasswordValidator,
            textMatchValidator: textMatchValidator,
            messageRecorder: resolve()
        )

        self.confirmPasswordTextFieldViewModel = PasswordTextFieldViewModel(
            with: .confirmNewPassword,
            passwordValidator: confirmNewPasswordValidator,
            textMatchValidator: textMatchValidator,
            messageRecorder: resolve()
        )

        let latestStatesObservable = Observable
            .combineLatest(
                currentPasswordTextFieldViewModel.state,
                passwordTextFieldViewModel.state,
                confirmPasswordTextFieldViewModel.state
            )

        let stateObservable = latestStatesObservable
            .map(weak: self) { (self, payload) -> FormPresentationState in
                try self.stateReducer.reduce(states: [payload.0, payload.1, payload.2])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchAndReturn(.invalid(.invalidTextField))
            .share(replay: 1)

        stateObservable
            .map(\.isValid)
            .bindAndCatch(to: buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        latestStatesObservable
            .compactMap { passwordState, newPasswordState, _ -> InteractionInput? in
                guard let currentPassword = passwordState.value else { return nil }
                guard let newPassword = newPasswordState.value else { return nil }
                return .init(currentPassword: currentPassword, newPassword: newPassword)
            }
            .bindAndCatch(to: interactor.contentRelay)
            .disposed(by: disposeBag)

        buttonViewModel.tapRelay
            .bindAndCatch(to: interactor.triggerRelay)
            .disposed(by: disposeBag)

        let interactorState = interactor.state.share(replay: 1, scope: .whileConnected)

        interactorState
            .map(\.isLoading)
            .bindAndCatch(weak: self, onNext: { (self, isLoading) in
                switch isLoading {
                case true:
                    self.loadingViewPresenter.showCircular()
                case false:
                    self.loadingViewPresenter.hide()
                }
            })
            .disposed(by: disposeBag)

        interactorState
            .filter(\.isComplete)
            .mapToVoid()
            .bindAndCatch(to: previousAPI.previousRelay)
            .disposed(by: disposeBag)

        interactorState
            .filter(\.isComplete)
            .mapToVoid()
            .subscribe { [weak self] _ in
                self?.coordinator.changePin()
            }
            .disposed(by: disposeBag)

        interactorState
            .filter { $0 == .incorrectPassword }
            .bindAndCatch(weak: self) { (self) in
                self.handleInteraction(error: "Your password is incorrect.")
            }
            .disposed(by: disposeBag)
    }

    /// Handles interaction errors by displaying an alert
    private func handleInteraction(error: String) {
        alertPresenter.notify(
            content: .init(
                title: LocalizationConstants.Errors.error,
                message: error
            )
        )
    }
}
