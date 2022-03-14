// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCUI
import Foundation
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

class ExchangeEmailVerificationViewController: UIViewController, BottomButtonContainerView {

    // MARK: Public Properties (Rx)

    var verificationObserver: Observable<Void> {
        verificationRelay.asObservable().take(1)
    }

    // MARK: Private Lazy Properties

    private lazy var presenter: VerifyEmailPresenter = VerifyEmailPresenter(view: self)

    private lazy var primaryFont: UIFont = Font(.branded(.montserratMedium), size: .custom(14.0)).result

    private lazy var primaryFontColor: UIColor = #colorLiteral(red: 0.21, green: 0.25, blue: 0.32, alpha: 1)

    private lazy var loadingAttributedText: NSAttributedString = {
        NSAttributedString(
            string: LocalizationConstants.Exchange.EmailVerification.justAMoment,
            attributes: [
                .font: primaryFont,
                .foregroundColor: primaryFontColor
            ]
        )
    }()

    private lazy var emailSentAttributedText: NSAttributedString = {
        NSAttributedString(
            string: LocalizationConstants.KYC.emailSent,
            attributes: [
                .font: primaryFont,
                .foregroundColor: primaryFontColor
            ]
        )
    }()

    private lazy var primaryAttributes: [NSAttributedString.Key: Any] = {
        [
            .font: primaryFont,
            .foregroundColor: primaryFontColor
        ]
    }()

    private lazy var secondaryAttributes: [NSAttributedString.Key: Any] = {
        [
            .font: primaryFont,
            .foregroundColor: #colorLiteral(red: 0.05, green: 0.42, blue: 0.95, alpha: 1)
        ]
    }()

    // MARK: Private Properties

    private var bag = DisposeBag()
    private var verificationRelay: PublishRelay<Void> = PublishRelay()
    private var email: String = "" {
        didSet {
            guard isViewLoaded else { return }
            emailTextField.text = email
        }
    }

    private var trigger: ActionableTrigger? {
        didSet {
            guard let trigger = trigger else { return }

            let primary = NSMutableAttributedString(
                string: trigger.primaryString + " ",
                attributes: primaryAttributes
            )
            let CTA = NSAttributedString(
                string: trigger.callToAction,
                attributes: secondaryAttributes
            )
            primary.append(CTA)
            resendEmailActionableLabel.attributedText = primary
        }
    }

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: Private IBOutlets

    @IBOutlet private var emailSentLabel: UILabel!
    @IBOutlet private var waitingLabel: UILabel!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var emailVerificationDescriptionLabel: UILabel!
    @IBOutlet private var resendEmailActionableLabel: ActionableLabel!
    @IBOutlet private var openMailButtonContainer: PrimaryButtonContainer!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.Exchange.EmailVerification.title
        resendEmailActionableLabel.delegate = self
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant

        emailSentLabel.attributedText = emailSentAttributedText
        waitingLabel.attributedText = loadingAttributedText

        presenter.email
            .subscribe(onSuccess: { [weak self] email in
                guard let self = self else { return }
                self.emailTextField.text = email
                self.presenter.sendVerificationEmail(to: email, contextParameter: .exchangeSignup)
            })
            .disposed(by: bag)

        trigger = ActionableTrigger(
            text: LocalizationConstants.Exchange.EmailVerification.didNotGetEmail,
            CTA: LocalizationConstants.Exchange.EmailVerification.sendAgain
        ) { [unowned self] in
            self.emailTextField.resignFirstResponder()
            self.presenter.sendVerificationEmail(to: self.email, contextParameter: .exchangeSignup)
        }

        openMailButtonContainer.actionBlock = {
            UIApplication.shared.openMailApplication()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        emailTextField.becomeFirstResponder()
        presenter.waitForEmailConfirmation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.cancel()
    }
}

extension ExchangeEmailVerificationViewController: EmailConfirmationInterface {
    func updateLoadingViewVisibility(_ visibility: Visibility) {
        openMailButtonContainer.isLoading = visibility.isHidden == false
        waitingLabel.isHidden = visibility.isHidden
        guard visibility == .visible else { return }
        resendEmailActionableLabel.isHidden = visibility.isHidden == false
    }

    func sendEmailVerificationSuccess() {
        emailSentLabel.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.emailSentLabel.isHidden = true
            self.resendEmailActionableLabel.isHidden = false
        }
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
        resendEmailActionableLabel.isHidden = false
    }

    func emailVerifiedSuccess() {
        verificationRelay.accept(())
    }
}

extension ExchangeEmailVerificationViewController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        trigger?.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        guard let trigger = trigger else { return }
        trigger.execute()
    }
}

extension ExchangeEmailVerificationViewController: NavigatableView {
    var leftNavControllerCTAType: NavigationCTAType {
        .none
    }

    var rightNavControllerCTAType: NavigationCTAType {
        .dismiss
    }

    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        dismiss(animated: true, completion: nil)
    }

    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        // no-op
    }
}
