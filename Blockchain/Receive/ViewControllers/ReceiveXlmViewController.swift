//
//  ReceiveXlmViewController.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

@objc class ReceiveXlmViewController: UIViewController {

    @IBOutlet private var labelInstructions: UILabel!
    @IBOutlet private var imageQrCode: UIImageView!
    @IBOutlet private var labelPublicKey: UILabel!
    @IBOutlet private var buttonEnterPassword: UIButton!
    @IBOutlet private var buttonRequestPayment: UIButton!

    private let wallet = WalletManager.shared.wallet
    private let xlmAccountRepository = WalletXlmAccountRepository()

    private var xlmAccount: WalletXlmAccount? {
        didSet {
            if let xlmAccount = xlmAccount {
                labelInstructions.text = LocalizationConstants.Receive.tapToCopyThisAddress
                imageQrCode.isHidden = false
                imageQrCode.image = QRCodeGenerator().createQRImage(from: xlmAccount.publicKey)
                labelPublicKey.text = xlmAccount.publicKey
                buttonEnterPassword.isHidden = true
                buttonRequestPayment.isHidden = false
            } else {
                labelInstructions.text = LocalizationConstants.Stellar.secondPasswordPrompt
                imageQrCode.isHidden = true
                labelPublicKey.text = ""
                buttonEnterPassword.isHidden = false
                buttonRequestPayment.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initXlmAccountIfNeeded()
    }

    // MARK: - Actions
    @IBAction private func onEnterPasswordTapped(_ sender: UIButton) {
        initXlmAccountIfNeeded()
    }

    @IBAction private func onAddressTapped(_ sender: Any) {
        guard let xlmAccount = xlmAccount else { return }
        UIPasteboard.general.string = xlmAccount.publicKey
        labelPublicKey.animate(
            fromText: labelPublicKey.text,
            toIntermediateText: LocalizationConstants.Receive.copiedToClipboard,
            speed: 1,
            gestureReceiver: labelPublicKey
        )
    }

    @IBAction private func onRequestPaymentTapped(_ sender: UIButton) {
        Logger.shared.debug("Request payment tapped.")
        guard let xlmAccount = xlmAccount else { return }

        let message = String(format: LocalizationConstants.Stellar.pleaseSendXlmToX, xlmAccount.publicKey)
        let items: [Any] = [message, self]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(LocalizationConstants.Stellar.xlmPaymentRequest, forKey: "subject")
        self.present(activityViewController, animated: true)
    }

    // MARK: - Private

    private func initXlmAccountIfNeeded() {
        xlmAccount = nil

        guard xlmAccountRepository.defaultAccount == nil else {
            Logger.shared.debug("XLM account is already initialized.")
            xlmAccount = xlmAccountRepository.defaultAccount
            return
        }

        guard !wallet.needsSecondPassword() else {
            AuthenticationCoordinator.shared.showPasswordConfirm(
                withDisplayText: LocalizationConstants.Stellar.secondPasswordPrompt,
                headerText: LocalizationConstants.Authentication.secondPasswordRequired,
                validateSecondPassword: true, confirmHandler: { [weak self] password in
                    self?.xlmAccountRepository.initializeMetadata(secondPassword: password)
                    self?.xlmAccount = self?.xlmAccountRepository.defaultAccount
                }
            )
            return
        }

        xlmAccountRepository.initializeMetadata()
        xlmAccount = xlmAccountRepository.defaultAccount
    }

    private func initViews() {
        buttonRequestPayment.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        buttonRequestPayment.setTitle(LocalizationConstants.Receive.requestPayment, for: .normal)

        buttonEnterPassword.layer.cornerRadius = Constants.Measurements.buttonCornerRadius
        buttonEnterPassword.setTitle(LocalizationConstants.Stellar.enterYourSecondPassword, for: .normal)
    }
}

extension ReceiveXlmViewController {
    @objc class func newInstance() -> ReceiveXlmViewController {
        return makeFromStoryboard()
    }
}
