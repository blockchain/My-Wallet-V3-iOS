//
//  KYCVerifyPhoneNumberController.swift
//  Blockchain
//
//  Created by Maurice A. on 7/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

final class KYCVerifyPhoneNumberController: UIViewController, KYCOnboardingNavigation {

    // MARK: Properties

    // TODO: user ID needs to be passed in to this view controller from previous step
    var userId: String? = ""

    var segueIdentifier: String? = "promptForAddress"

    @IBOutlet var textFieldMobileNumber: UITextField!
    @IBOutlet var primaryButton: PrimaryButton!

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
            Logger.shared.warning("userId is nil.")
            return
        }
        presenter.verify(number: number, userId: userId)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: implement method body
    }

    private func goToNextStep() {
        guard let segueIdentifier = segueIdentifier else {
            Logger.shared.info("segueIdentifier is nil. Can't go to next step.")
            return
        }
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}

extension KYCVerifyPhoneNumberController: KYCVerifyPhoneNumberView {
    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        LoadingViewPresenter.shared.showBusyView(withLoadingText: text)
    }

    func showEnterVerificationCodeView() {
        Logger.shared.info("Show verification view!")
        // TODO: Decision on whether or not an alert or another view should be presented is TBD,
        // for now, just go to the next step
        goToNextStep()
    }

    func hideLoadingView() {
        LoadingViewPresenter.shared.hideBusyView()
    }
}
