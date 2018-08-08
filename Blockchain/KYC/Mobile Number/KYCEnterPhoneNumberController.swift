//
//  KYCEnterPhoneNumberController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PhoneNumberKit
import UIKit

final class KYCEnterPhoneNumberController: UIViewController {

    // MARK: Properties

    var userId: String?

    // MARK: IBOutlets

    @IBOutlet private var validationTextFieldMobileNumber: ValidationTextField!
    @IBOutlet private var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: Private Properties

    private var originalBottomButtonConstraint: CGFloat!

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = { [unowned self] in
        return KYCVerifyPhoneNumberPresenter(view: self)
    }()

    private lazy var phoneNumberPartialFormatter: PartialFormatter = {
        return PartialFormatter()
    }()

    // MARK: UIViewController Lifecycle Methods

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TICKET: IOS-1141 display correct % in the progress view
        validationTextFieldMobileNumber.keyboardType = .numberPad
        validationTextFieldMobileNumber.contentType = .telephoneNumber
        validationTextFieldMobileNumber.textReplacementBlock = { [unowned self] in
            return self.phoneNumberPartialFormatter.formatPartial($0)
        }
        validationTextFieldMobileNumber.returnTappedBlock = { [unowned self] in
            self.validationTextFieldMobileNumber.resignFocus()
        }
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
        validationTextFieldMobileNumber.becomeFocused()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard case .valid = validationTextFieldMobileNumber.validate() else {
            Logger.shared.warning("phone number field is invalid.")
            return
        }
        guard let number = validationTextFieldMobileNumber.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        guard let userId = userId else {
            Logger.shared.warning("userId is nil.")
            return
        }
        presenter.startVerification(number: number, userId: userId)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let confirmPhoneNumberViewController = segue.destination as? KYCConfirmPhoneNumberController else {
            return
        }
        confirmPhoneNumberViewController.userId = userId
        confirmPhoneNumberViewController.phoneNumber = validationTextFieldMobileNumber.text ?? ""
    }

    // MARK: - Private Methods

    private func keyboardWillShow(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint + payload.endingFrame.height
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }

    private func keyboardWillHide(with payload: KeyboardPayload) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.animationDuration)
        UIView.setAnimationCurve(payload.animationCurve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
}

extension KYCEnterPhoneNumberController: KYCVerifyPhoneNumberView {
    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
    }

    func startVerificationSuccess() {
        Logger.shared.info("Show verification view!")
        self.performSegue(withIdentifier: "verifyMobileNumber", sender: nil)
    }

    func hideLoadingView() {
        LoadingViewPresenter.shared.hideBusyView()
    }
}
