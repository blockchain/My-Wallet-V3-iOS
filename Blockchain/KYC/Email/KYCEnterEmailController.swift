//
//  KYCEnterEmailController.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

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

    private lazy var presenter: KYCVerifyEmailPresenter = {
        return KYCVerifyEmailPresenter(view: self)
    }()

    // MARK: KYCBaseViewController

    override class func make(with coordinator: KYCCoordinator) -> KYCEnterEmailController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .enterEmail
        return controller
    }

    override func apply(model: KYCPageModel) {
        guard case let .email(user) = model else { return }

        validationTextFieldEmail.text = user.email.address
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
            self.validationTextFieldEmail.resignFocus()
        }
        validationTextFieldEmail.validationBlock = { value in
            guard let email = value else { return .invalid(nil) }
            if (email as NSString).isEmail() {
                return .valid
            }
            return .invalid(nil)
        }
        primaryButton.actionBlock = { [unowned self] in
            self.primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        
        AnalyticsService.shared.trackEvent(title: "kyc_email")
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
        presenter.sendVerificationEmail(to: email)
    }
}

extension KYCEnterEmailController: KYCVerifyEmailView {
    func showLoadingView() {
        primaryButton.isLoading = true
    }

    func sendEmailVerificationSuccess() {
        guard let email = validationTextFieldEmail.text else {
            Logger.shared.warning("email is nil.")
            return
        }
        Logger.shared.info("Show verification view!")
        let payload = KYCPagePayload.emailPendingVerification(email: email)
        coordinator.handle(event: .nextPageFromPageType(pageType, payload))
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }
    
    func hideLoadingView() {
        primaryButton.isLoading = false
    }
}
