//
//  KYCConfirmPhoneNumberController.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCConfirmPhoneNumberController: UIViewController {

    @IBOutlet private var nextButton: PrimaryButton!
    @IBOutlet private var labelPhoneNumber: UILabel!
    @IBOutlet private var textFieldConfirmationCode: UITextField!
    @IBOutlet private var layoutConstraintBottomButton: NSLayoutConstraint!

    var phoneNumber: String = "" {
        didSet {
            guard isViewLoaded else { return }
            labelPhoneNumber.text = phoneNumber
        }
    }

    var userId: String?

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = {
        return KYCVerifyPhoneNumberPresenter(view: self)
    }()
    private var originalBottomButtonConstraint: CGFloat!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        labelPhoneNumber.text = phoneNumber
        nextButton.isEnabled = false
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.when(NSNotification.Name.UIKeyboardWillShow) {
            self.keyboardWillShow(with: KeyboardPayload(notification: $0))
        }
        NotificationCenter.when(NSNotification.Name.UIKeyboardWillHide) {
            self.keyboardWillHide(with: KeyboardPayload(notification: $0))
        }
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
        guard let code = textFieldConfirmationCode.text else {
            Logger.shared.warning("code is nil.")
            return
        }
        guard let userId = userId else {
            Logger.shared.warning("userIs is nil.")
            return
        }
        presenter.verify(number: phoneNumber, userId: userId, code: code)
    }

    @IBAction func onTextFieldChanged(_ sender: Any) {
        nextButton.isEnabled = !(textFieldConfirmationCode.text?.isEmpty ?? true)
    }

    // MARK: Private

    private func keyboardWillShow(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint + payload.endingFrame.height
        UIView.commitAnimations()
    }

    private func keyboardWillHide(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint
        UIView.commitAnimations()
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
