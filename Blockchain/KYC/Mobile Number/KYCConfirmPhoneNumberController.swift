//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class KYCConfirmPhoneNumberController: KYCBaseViewController, BottomButtonContainerView {

    // MARK: Public Properties

    var phoneNumber: String = "" {
        didSet {
            guard isViewLoaded else { return }
            labelPhoneNumber.text = phoneNumber
        }
    }

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelPhoneNumber: UILabel!
    @IBOutlet private var validationTextFieldConfirmationCode: ValidationTextField!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = {
        return KYCVerifyPhoneNumberPresenter(view: self)
    }()

    deinit {
        cleanUp()
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCConfirmPhoneNumberController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .confirmPhone
        return controller
    }

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        validationTextFieldConfirmationCode.autocapitalizationType = .allCharacters
        labelPhoneNumber.text = phoneNumber
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        validationTextFieldConfirmationCode.becomeFocused()
        primaryButton.actionBlock = { [unowned self] in
            self.onNextTapped()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        validationTextFieldConfirmationCode.becomeFocused()
    }

    // MARK: - KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .phone(user) = model else { return }

        guard let mobile = user.mobile, phoneNumber.count == 0 else { return }
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
        coordinator.handle(event: .nextPageFromPageType(pageType, nil))
    }

    func startVerificationSuccess() {
        Logger.shared.info("Verification code sent.")
    }

    func hideLoadingView() {
        primaryButton.isLoading = false
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        primaryButton.isLoading = true
    }
}
