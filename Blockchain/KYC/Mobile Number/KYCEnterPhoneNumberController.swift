//
//  KYCEnterPhoneNumberController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class KYCEnterPhoneNumberController: UIViewController {

    // MARK: Properties

    var userId: String?

    @IBOutlet var textFieldMobileNumber: UITextField!

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = { [unowned self] in
        return KYCVerifyPhoneNumberPresenter(view: self)
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldMobileNumber.becomeFirstResponder()
    }

    // MARK: - Actions

    @IBAction func primaryButtonTapped(_ sender: Any) {
        guard let number = textFieldMobileNumber.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        guard let userId = userId else {
            Logger.shared.warning("userIs is nil.")
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
        confirmPhoneNumberViewController.phoneNumber = textFieldMobileNumber.text ?? ""
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
