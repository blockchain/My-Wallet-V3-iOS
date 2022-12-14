// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationUI
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

final class PinScreenViewController: BaseScreenViewController {

    // MARK: - Properties

    @IBOutlet private var digitPadView: DigitPadView!
    @IBOutlet private var securePinView: SecurePinView!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var remainingLockTimeLabel: UILabel!

    @IBOutlet private var digitPadBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var securePinViewTopConstraint: NSLayoutConstraint!

    private lazy var sheetPresenter: BottomSheetPresenting = BottomSheetPresenting(ignoresBackgroundTouches: false)
    // swiftlint:disable weak_delegate
    private lazy var adaptivePresentationControllerDelegate = PinScreenAdaptivePresentationControllerDelegate()

    private let presenter: PinScreenPresenter
    private let alertViewPresenter: AlertViewPresenterAPI

    private let recorder: Recording

    private var serverStatusContainerView: UIStackView!
    private let serverStatusTitleLabel = UILabel()
    private let serverStatusSubtitleLabel = InteractableTextView()

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(
        using presenter: PinScreenPresenter,
        recorder: Recording = DIKit.resolve(tag: "CrashlyticsRecorder"),
        alertViewPresenter: AlertViewPresenterAPI = resolve()
    ) {
        self.presenter = presenter
        self.recorder = recorder
        self.alertViewPresenter = alertViewPresenter
        super.init(nibName: String(describing: PinScreenViewController.self), bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupErrorLabel()
        setupLockTimeLabel()
        createServerStatusView()
        presenter.viewDidLoad()
        digitPadView.viewModel = presenter.digitPadViewModel
        securePinView.viewModel = presenter.securePinViewModel

        switch DevicePresenter.type {
        case .superCompact:
            // SE
            digitPadBottomConstraint.constant = 0
            securePinViewTopConstraint.constant = 10
        case .compact:
            // iPhone 8
            digitPadBottomConstraint.constant = 0
            securePinViewTopConstraint.constant = 30
        case .regular, .max:
            break
        }
        // Subscribe to pin changes
        presenter.pin
            .bind { [weak self] pin in
                guard pin != nil else { return }
                self?.respondToPinChange()
            }
            .disposed(by: disposeBag)

        serverStatusContainerView.isHidden = true

        // Subscribe to digit pad visibility state
        presenter
            .digitPadIsEnabled
            .subscribe(
                with: self,
                onNext: { (self, isEnabled) in
                    self.digitPadView.isUserInteractionEnabled = isEnabled
                    self.digitPadView.alpha = isEnabled ? 1 : 0.3
                }
            )
            .disposed(by: disposeBag)

        presenter
            .digitPadIsEnabled
            .bindAndCatch(to: remainingLockTimeLabel.rx.isHidden)
            .disposed(by: disposeBag)

        presenter
            .remainingLockTimeMessage
            .distinctUntilChanged()
            .bindAndCatch(to: remainingLockTimeLabel.rx.text)
            .disposed(by: disposeBag)

        NotificationCenter.when(UIApplication.willEnterForegroundNotification) { [weak self] _ in
            self?.prepareForAppearance()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.authenticateUsingBiometricsIfNeeded()

        #if DEBUG
        becomeFirstResponder()
        #endif
    }

    // MARK: - Setup

    // TODO: @native-wallet Remove this, remove UI components, check UI loads OK.
    private func createServerStatusView() {
        serverStatusContainerView = UIStackView(arrangedSubviews: [serverStatusTitleLabel, serverStatusSubtitleLabel])
        serverStatusContainerView.axis = .vertical
        serverStatusContainerView.spacing = 8
        serverStatusContainerView.backgroundColor = UIColor.darkBlueBackground
        serverStatusContainerView.isLayoutMarginsRelativeArrangement = true
        serverStatusContainerView.directionalLayoutMargins = .init(
            top: Spacing.inner,
            leading: Spacing.inner,
            bottom: Spacing.inner,
            trailing: Spacing.inner
        )
        view.addSubview(serverStatusContainerView)

        serverStatusTitleLabel.font = UIFont.main(.bold, 16)
        serverStatusTitleLabel.textColor = UIColor.red
        serverStatusTitleLabel.textAlignment = .left
        serverStatusTitleLabel.numberOfLines = 2

        serverStatusSubtitleLabel.font = UIFont.main(.medium, 16)
        serverStatusSubtitleLabel.textColor = .white
        serverStatusSubtitleLabel.textAlignment = .left
        serverStatusSubtitleLabel.backgroundColor = .clear

        serverStatusContainerView.layer.cornerRadius = 8
        serverStatusContainerView.layoutToSuperview(.top, relation: .equal, usesSafeAreaLayoutGuide: true, offset: 10)
        serverStatusContainerView.layoutToSuperview(.leading, relation: .equal, usesSafeAreaLayoutGuide: true, offset: 10)
        serverStatusContainerView.layoutToSuperview(.trailing, relation: .equal, usesSafeAreaLayoutGuide: true, offset: -10)
        securePinView.layout(edge: .top, to: .bottom, of: serverStatusContainerView, relation: .equal, offset: 18, priority: .required)
    }

    private func prepareForAppearance() {
        presenter.reset()
    }

    private func setupNavigationBar() {
        parent?.view.backgroundColor = presenter.backgroundColor
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        titleViewStyle = presenter.titleView

        // Subscribe to `isProcessing` indicates whether something is processing in the background
        presenter.isProcessing
            .bind { [weak self] isProcessing in
                guard let self else { return }
                self.view.isUserInteractionEnabled = !isProcessing
                self.trailingButtonStyle = isProcessing ? .processing : self.presenter.trailingButton
            }
            .disposed(by: disposeBag)
    }

    private func setupErrorLabel() {
        errorLabel.accessibility = .id(AccessibilityIdentifiers.PinScreen.errorLabel)
        errorLabel.font = .main(.semibold, 15.0)
        errorLabel.textColor = presenter.contentColor
    }

    private func setupLockTimeLabel() {
        remainingLockTimeLabel.accessibility =
            .id(AccessibilityIdentifiers.PinScreen.lockTimeLabel)
        remainingLockTimeLabel.font = .main(.semibold, 15.0)
        remainingLockTimeLabel.textColor = presenter.contentColor
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        if presenter.useCase.isAuthenticateOnLogin {
            displayLogoutWarningAlert()
        } else {
            presenter.backwardRouting()
        }
    }

    override func navigationBarTrailingButtonPressed() {
        presentSupportViewFromViewController(
            self,
            transitioningDelegate: sheetPresenter
        )
    }
}

// MARK: - Presenter Interaction & Feedback

extension PinScreenViewController {

    /// Accepts a valid pin value
    private func respondToPinChange() {
        errorLabel.alpha = 0
        switch presenter.useCase {
        case .select:
            selectPin()
        case .create:
            createPin()
        case .authenticateBeforeChanging:
            authenticatePinBeforeChanging()
        case .authenticateOnLogin, .authenticateBeforeEnablingBiometrics:
            authenticatePin()
        }
    }

    /// Handle any kind of error returned by the presenter
    private func handle(error: Error) {
        view.isUserInteractionEnabled = false
        let deferred = { [weak self] in
            guard let self else { return }
            self.view.isUserInteractionEnabled = true
            self.presenter.reset()
        }

        var optionalRecovery: (() -> Void)?

        let error = PinError.map(from: error)
        recorder.record("handle(error:) occurred with error: \(error)")
        switch error {
        case .pinMismatch(recovery: let recovery):
            showInlineError(with: LocalizationConstants.Pin.pinsDoNotMatch)
            optionalRecovery = recovery
        case .identicalToPrevious:
            showInlineError(with: LocalizationConstants.Pin.newPinMustBeDifferent)
        case .invalid:
            showInlineError(with: LocalizationConstants.Pin.chooseAnotherPin)
        case .incorrectPin(let message, let remaining, let pinAlert):
            let remainingSeconds = Int(remaining / 1000)
            presenter.digitPadViewModel.remainingLockTimeDidChange(remaining: remainingSeconds)
            remainingSeconds > 0 ?
                showInlineError(with: message, for: TimeInterval(remainingSeconds - 1)) :
                showInlineError(with: message)
            if let alert = pinAlert {
                displayPinAlert(pinAlert: alert)
            }
        case .backoff(let message, let remaining, let pinAlert):
            let remainingSeconds = Int(remaining / 1000)
            presenter.digitPadViewModel.remainingLockTimeDidChange(remaining: remainingSeconds)
            showInlineError(with: message, for: TimeInterval(remainingSeconds - 1))
            if let alert = pinAlert {
                displayPinAlert(pinAlert: alert)
            }
        case .tooManyAttempts:
            displayLogoutAlert()
        case .noInternetConnection(recovery: let recovery):
            let alertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnection,
                actions: [
                    UIAlertAction(
                        title: LocalizationConstants.okString,
                        style: .cancel,
                        handler: { _ in recovery() }
                    )
                ]
            )
            alertViewPresenter.notify(content: alertContent, in: self)
        case .serverMaintenance(message: let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .serverError(message: let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .receivedResponseWhileLoggedOut:
            return
        case .custom(let message):
            alertViewPresenter.standardError(message: message, in: self)
        case .biometricAuthenticationFailed(let message):
            alertViewPresenter.standardError(message: message, in: self)
        default:
            showInlineError(with: LocalizationConstants.Pin.genericError)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.error)
        let animator = securePinView.joltAnimator
        animator.addCompletion { [weak self] _ in
            guard let optionalRecovery else {
                deferred()
                self?.recorder.record("handle(error:), only deferred block called")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                deferred()
                optionalRecovery()
                self?.recorder.record("handle(error:), deferred & optionalRecovery blocks called")
            }
        }
        animator.startAnimation()
    }

    private func showInlineError(with text: String, for duration: TimeInterval? = nil) {
        errorLabel.text = text
        errorLabel.alpha = 1
        guard let durationTime = duration else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + durationTime) { [weak self] in
            self?.errorLabel.alpha = 0
        }
    }

    private func displayPinAlert(pinAlert: PinError.PinAlert) {
        switch pinAlert {
        case .tooManyAttempts:
            displayTooManyAttemptsAlert()
        case .cannotLogin:
            displayCannotLoginAlert()
        }
    }

    /// Displays a warning alert when users have too many wrong attempts
    private func displayTooManyAttemptsAlert() {
        let alertController = TooManyAttemptsAlertViewController()
        present(alertController, animated: true)
    }

    /// Displays forgot your PIN warning alert when users have used up all PIN login attempts
    private func displayCannotLoginAlert() {
        let alertController = CannotLoginAlertViewController()
        present(alertController, animated: true)
    }

    /// Displays a logout warning alert when the user taps the `Log out` button
    private func displayLogoutWarningAlert() {
        let actions = [
            UIAlertAction(title: LocalizationConstants.okString, style: .default, handler: { [weak self] _ in
                self?.presenter.logout()
            }),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        let content = AlertViewContent(
            title: LocalizationConstants.Pin.LogoutAlert.title,
            message: LocalizationConstants.Pin.LogoutAlert.message,
            actions: actions
        )
        alertViewPresenter.notify(content: content, in: self)
    }

    /// Displays alert telling the user he has exhausted the max allowed number of PIN retries.
    private func displayLogoutAlert() {
        let alertView = AlertView.make(with: presenter.logoutAlertModel) { [weak self] _ in
            self?.presenter.logout()
        }
        alertView.show()
    }

    private func displaySetPinSuccessAlertIfNeeded() {
        let success = { [weak presenter] in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            presenter?.didSetPinSuccessfully()
        }
        guard let model = presenter.setPinSuccessAlertModel else {
            success()
            return
        }
        let alertView = AlertView.make(with: model) { _ in
            success()
        }
        alertView.show()
    }

    private func displayEnableBiometricsAlertIfNeeded(completion: @escaping () -> Void) {
        if #available(iOS 15.0, *) {
            guard let model = presenter.biometricsSheetModel else {
                completion()
                return
            }
            let view = PinScreenEnableBiometricsInfoView(
                viewModel: model,
                completion: { [weak self] in
                    self?.dismiss(animated: true, completion: completion)
                }
            )
            let controller = UIHostingController(rootView: view)
            adaptivePresentationControllerDelegate.onDidDismissCompletion = completion
            controller.presentationController?.delegate = adaptivePresentationControllerDelegate
            controller.modalPresentationStyle = .pageSheet
            if let sheet = controller.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [
                        .custom { _ in 360 }
                    ]
                } else {
                    sheet.detents = [
                        .medium()
                    ]
                }
                sheet.prefersGrabberVisible = true
            }
            present(controller, animated: true)
        } else {
            guard let model = presenter.biometricsAlertModel else {
                completion()
                return
            }
            let alertView = AlertView.make(with: model) { action in
                switch action.metadata {
                case .some(.block(let block)):
                    block()
                default:
                    break
                }
                completion()
            }
            alertView.show()
        }
    }

    /// Called after setting the pin successfully on both create & change flows
    private func setPinSuccess() {
        displayEnableBiometricsAlertIfNeeded { [weak self] in
            self?.displaySetPinSuccessAlertIfNeeded()
        }
    }

    // Invoked upon first selection of PIN (creation / change flow)
    private func selectPin() {
        presenter.validateFirstEntry()
            .subscribe(onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }

    // Invoked upon creation of a new PIN (creation / change flow)
    private func createPin() {
        presenter.validateSecondEntry()
            .subscribe(onCompleted: { [weak self] in
                self?.setPinSuccess()
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }

    // Standard login authentication / before configuring biometrics
    private func authenticatePin() {
        presenter.authenticatePin()
            .subscribe(onCompleted: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }

    // Authentication before choosing another pin
    private func authenticatePinBeforeChanging() {
        presenter.verifyPinBeforeChanging()
            .subscribe(onCompleted: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }, onError: { [weak self] error in
                self?.handle(error: error)
            })
            .disposed(by: disposeBag)
    }
}

private final class PinScreenAdaptivePresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    var onDidDismissCompletion: (() -> Void)?
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDidDismissCompletion?()
        onDidDismissCompletion = nil
    }
}

// MARK: - NavigationTransitionAnimating

extension PinScreenViewController: NavigationTransitionAnimating {
    func prepareForAppearance(for transition: ScreenTransitioningAnimator.TransitionType) {
        let joltOffset = presenter.securePinViewModel.joltOffset
        switch transition {
        case .pushIn:
            securePinView.transform = CGAffineTransform(translationX: -joltOffset, y: 0)
        case .pushOut:
            securePinView.transform = CGAffineTransform(translationX: joltOffset, y: 0)
        }
        securePinView.alpha = 0
    }

    func appearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: transition.duration * 0.5, curve: .easeOut)
        animator.addAnimations {
            self.securePinView.alpha = 1
            self.securePinView.transform = .identity
        }
        return animator
    }

    func disappearancePropertyAnimator(for transition: ScreenTransitioningAnimator.TransitionType) -> UIViewPropertyAnimator {
        let duration: TimeInterval = transition.duration * 0.5
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        let joltOffset = presenter.securePinViewModel.joltOffset
        animator.addAnimations {
            self.securePinView.alpha = 0
            self.errorLabel.alpha = 0
            switch transition {
            case .pushIn:
                self.securePinView.transform = CGAffineTransform(translationX: joltOffset, y: 0)
            case .pushOut:
                self.securePinView.transform = CGAffineTransform(translationX: -joltOffset, y: 0)
            }
        }
        return animator
    }
}
