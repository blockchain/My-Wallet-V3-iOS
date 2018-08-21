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

    var userId: String?

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var labelPhoneNumber: UILabel!
    @IBOutlet private var validationTextFieldConfirmationCode: ValidationTextField!

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
        // TICKET: IOS-1141 display correct % in the progress view
        validationTextFieldConfirmationCode.autocapitalizationType = .allCharacters
        labelPhoneNumber.text = phoneNumber
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        validationTextFieldConfirmationCode.becomeFocused()
    }

    // MARK: IBActions
    @IBAction func onResendCodeTapped(_ sender: Any) {
        guard let userId = userId else {
            Logger.shared.warning("userIs is nil.")
            return
        }
        presenter.startVerification(number: phoneNumber, userId: userId)
    }

    @IBAction func onNextTapped(_ sender: Any) {
        guard case .valid = validationTextFieldConfirmationCode.validate() else {
            validationTextFieldConfirmationCode.becomeFocused()
            Logger.shared.warning("text field is invalid.")
            return
        }
        guard let code = validationTextFieldConfirmationCode.text else {
            Logger.shared.warning("code is nil.")
            return
        }
        guard let userId = userId else {
            Logger.shared.warning("userId is nil.")
            return
        }
        presenter.verify(number: phoneNumber, userId: userId, code: code)
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
        LoadingViewPresenter.shared.hideBusyView()
    }

    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
    }
}
