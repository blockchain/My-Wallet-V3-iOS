//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmPhoneNumberController: UIViewController {

    @IBOutlet var nextButton: PrimaryButton!
    @IBOutlet var labelPhoneNumber: UILabel!
    @IBOutlet var textFieldConfirmationCode: UITextField!
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    var phoneNumber: String = "" {
        didSet {
            guard isViewLoaded else { return }
            labelPhoneNumber.text = phoneNumber
        }
    }

    var userId: String = ""

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = {
        return KYCVerifyPhoneNumberPresenter(view: self)
    }()

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        labelPhoneNumber.text = phoneNumber
        nextButton.isEnabled = false
    }

    // MARK: IBActions
    @IBAction func onResendCodeTapped(_ sender: Any) {
        presenter.startVerification(number: phoneNumber, userId: userId)
    }

    @IBAction func onNextTapped(_ sender: Any) {
        guard let code = textFieldConfirmationCode.text else { return }
        presenter.verify(number: phoneNumber, userId: userId, code: code)
    }

    @IBAction func onTextFieldChanged(_ sender: Any) {
        nextButton.isEnabled = !(textFieldConfirmationCode.text?.isEmpty ?? true)
    }
}

extension KYCConfirmPhoneNumberController: KYCConfirmPhoneNumberView {
    func confirmCodeSuccess() {
        self.performSegue(withIdentifier: "promptForAddress", sender: nil)
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
