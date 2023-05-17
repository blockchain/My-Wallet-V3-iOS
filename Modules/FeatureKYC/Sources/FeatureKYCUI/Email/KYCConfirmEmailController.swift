// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

class KYCConfirmEmailController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = UIColor.semantic.success
    var startingValue: Float = 0.2

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var validationTextFieldEmail: ValidationTextField!
    @IBOutlet private var buttonDidntGetEmail: PrimaryButtonContainer!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    // MARK: Private Properties

    private lazy var presenter: VerifyEmailPresenter = VerifyEmailPresenter(view: self)

    // MARK: Properties

    var email: String = "" {
        didSet {
            guard isViewLoaded else { return }
            validationTextFieldEmail.text = email
        }
    }

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCConfirmEmailController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .confirmEmail
        return controller
    }

    // MARK: - UIViewController Lifecycle Methods

    deinit {
        cleanUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeader.text = LocalizationConstants.KYC.checkYourInbox
        labelSubHeader.text = LocalizationConstants.KYC.confirmEmailExplanation
        validationTextFieldEmail.text = email
        validationTextFieldEmail.isEnabled = false
        validationTextFieldEmail.accessibilityIdentifier = "kyc.email_field"
        let attributedTitle = NSMutableAttributedString(string: LocalizationConstants.KYC.didntGetTheEmail + " " + LocalizationConstants.KYC.sendAgain)
        attributedTitle.addForegroundColor(buttonDidntGetEmail.buttonTitleColor, to: LocalizationConstants.KYC.didntGetTheEmail)
        attributedTitle.addForegroundColor(#colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1), to: LocalizationConstants.KYC.sendAgain)
        buttonDidntGetEmail.attributedTitle = attributedTitle
        buttonDidntGetEmail.primaryButtonFont = 2
        buttonDidntGetEmail.activityIndicatorStyle = .medium
        buttonDidntGetEmail.actionBlock = { [unowned self] in
            sendVerificationEmail()
        }
        primaryButton.title = LocalizationConstants.KYC.openEmailApp
        primaryButton.actionBlock = { [unowned self] in
            primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setupProgressView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        presenter.waitForEmailConfirmation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.cancel()
    }

    // MARK: - Actions

    private func sendVerificationEmail() {
        guard email.isEmail else {
            return
        }
        presenter.sendVerificationEmail(to: email)
    }

    private func primaryButtonTapped() {
        UIApplication.shared.openMailApplication()
    }
}

extension KYCConfirmEmailController: EmailConfirmationInterface {
    func updateLoadingViewVisibility(_ visibility: Visibility) {
        buttonDidntGetEmail.isLoading = visibility.isHidden == false
    }

    func sendEmailVerificationSuccess() {
        let origTitle = buttonDidntGetEmail.title
        let origColor = buttonDidntGetEmail.buttonTitleColor

        buttonDidntGetEmail.title = LocalizationConstants.KYC.emailSent
        buttonDidntGetEmail.buttonTitleColor = UIColor.green

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.buttonDidntGetEmail.title = origTitle
            strongSelf.buttonDidntGetEmail.buttonTitleColor = origColor
        }
    }

    func showError(message: String) {
        let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
        alertPresenter.standardError(message: message, in: self)
    }

    func hideLoadingView() {
        buttonDidntGetEmail.isLoading = false
    }

    func emailVerifiedSuccess() {
        Logger.shared.info("Email is verified.")
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }
}
