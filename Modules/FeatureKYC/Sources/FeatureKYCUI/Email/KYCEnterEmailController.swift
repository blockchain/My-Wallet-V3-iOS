// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

class KYCEnterEmailController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.1

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelHeader: UILabel!
    @IBOutlet private var labelSubHeader: UILabel!
    @IBOutlet private var validationTextFieldEmail: ValidationTextField!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    // MARK: Private Properties

    private lazy var presenter: VerifyEmailPresenter = VerifyEmailPresenter(view: self)

    @Inject private var analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: KYCBaseViewController

    override class func make(with coordinator: KYCRouter) -> KYCBaseViewController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .enterEmail
        return controller
    }

    override func apply(model: KYCPageModel) {
        guard case .email(let user) = model else { return }

        validationTextFieldEmail.text = user.email.address
        validationTextFieldEmail.accessibilityIdentifier = "kyc.email_field"
    }

    // MARK: - UIViewController Lifecycle Methods

    deinit {
        cleanUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        labelHeader.text = LocalizationConstants.KYC.whyDoWeNeedThis
        labelSubHeader.text = LocalizationConstants.KYC.enterEmailExplanation
        validationTextFieldEmail.keyboardType = .emailAddress
        validationTextFieldEmail.contentType = .emailAddress
        validationTextFieldEmail.returnTappedBlock = { [unowned self] in
            validationTextFieldEmail.resignFocus()
        }
        validationTextFieldEmail.validationBlock = { value in
            guard let email = value else { return .invalid(nil) }
            if email.isEmail {
                return .valid
            }
            return .invalid(nil)
        }
        primaryButton.actionBlock = { [unowned self] in
            primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setupProgressView()
        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycEmail)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        validationTextFieldEmail.becomeFocused()
    }

    // MARK: - Actions

    private func primaryButtonTapped() {
        guard case .valid = validationTextFieldEmail.validate(withStyling: true) else {
            validationTextFieldEmail.becomeFocused()
            Logger.shared.warning("email field is invalid.")
            return
        }
        guard let email = validationTextFieldEmail.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVerifyEmailButtonClick)
        presenter.sendVerificationEmail(to: email)
    }
}

extension KYCEnterEmailController: EmailVerificationInterface {

    func updateLoadingViewVisibility(_ visibility: Visibility) {
        primaryButton.isLoading = visibility.isHidden == false
    }

    func sendEmailVerificationSuccess() {
        guard let email = validationTextFieldEmail.text else {
            Logger.shared.warning("email is nil.")
            return
        }
        Logger.shared.info("Show verification view!")
        let payload = KYCPagePayload.emailPendingVerification(email: email)
        router.handle(event: .nextPageFromPageType(pageType, payload))
    }

    func showError(message: String) {
        let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
        alertPresenter.standardError(message: message, in: self)
    }
}
