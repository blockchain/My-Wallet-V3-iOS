// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import PlatformKit
import PlatformUIKit
import ToolKit

final class KYCConfirmPhoneNumberController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.75
    @IBOutlet var progressView: UIProgressView!

    // MARK: Public Properties

    var phoneNumber: String = "" {
        didSet {
            guard isViewLoaded else { return }
            labelPhoneNumber.text = phoneNumber
        }
    }

    // MARK: BottomButtonContainerView

    var optionalOffset: CGFloat = 0
    var originalBottomButtonConstraint: CGFloat!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelPhoneNumber: UILabel!
    @IBOutlet private var validationTextFieldConfirmationCode: ValidationTextField!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = KYCVerifyPhoneNumberPresenter(view: self)

    deinit {
        cleanUp()
    }

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCConfirmPhoneNumberController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .confirmPhone
        return controller
    }

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        validationTextFieldConfirmationCode.autocapitalizationType = .allCharacters
        validationTextFieldConfirmationCode.contentType = .oneTimeCode

        labelPhoneNumber.text = phoneNumber
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        validationTextFieldConfirmationCode.becomeFocused()
        primaryButton.actionBlock = { [unowned self] in
            onNextTapped()
        }
        setupProgressView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        validationTextFieldConfirmationCode.becomeFocused()
    }

    // MARK: - KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .phone(let user) = model else { return }

        guard let mobile = user.mobile, phoneNumber.isEmpty else { return }
        phoneNumber = mobile.phone
    }

    // MARK: Actions

    @IBAction func onResendCodeTapped(_ sender: Any) {
        presenter.startVerification(number: phoneNumber)
    }

    private func onNextTapped() {
        guard case .valid = validationTextFieldConfirmationCode.validate() else {
            validationTextFieldConfirmationCode.becomeFocused()
            Logger.shared.warning("text field is invalid.")
            return
        }
        guard let code = validationTextFieldConfirmationCode.text else {
            Logger.shared.warning("code is nil.")
            return
        }
        presenter.verifyNumber(with: code)
    }
}

extension KYCConfirmPhoneNumberController: KYCConfirmPhoneNumberView {
    func confirmCodeSuccess() {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    func startVerificationSuccess() {
        Logger.shared.info("Verification code sent.")
    }

    func hideLoadingView() {
        primaryButton.isLoading = false
    }

    func showError(message: String) {
        let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
        alertPresenter.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        primaryButton.isLoading = true
    }
}
