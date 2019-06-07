//
//  ReceiveCryptoViewController.swift
//  PlatformUIKit
//
//  Created by Chris Arriola on 5/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// A `CryptoCurrency` agnostic screen for receiving funds into a provided address.
/// The view of this class can be configured by providing a `ReceiveCryptoViewModel`
public class ReceiveCryptoViewController: UIViewController {

    @IBOutlet private var labelInstructions: UILabel!
    @IBOutlet private var imageQrCode: UIImageView!
    @IBOutlet private var labelPublicKey: UILabel!
    @IBOutlet private var buttonEnterPassword: UIButton!
    @IBOutlet private var buttonRequestPayment: UIButton!

    public var viewModel: ReceiveCryptoViewModelProtocol?

    private var walletAccount: WalletAccount? {
        didSet {
            if let walletAccount = walletAccount {
                labelInstructions.text = viewModel?.textViewModel.tapToCopyThisAddress
                imageQrCode.isHidden = false
                let qrCode = viewModel?.qrCode(from: walletAccount)
                imageQrCode.image = qrCode?.image
                labelPublicKey.text = walletAccount.publicKey
                buttonEnterPassword.isHidden = true
                buttonRequestPayment.isHidden = false
            } else {
                labelInstructions.text = viewModel?.textViewModel.secondPasswordPrompt
                imageQrCode.isHidden = true
                labelPublicKey.text = ""
                buttonEnterPassword.isHidden = false
                buttonRequestPayment.isHidden = true
            }
        }
    }
    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initCryptoAccountIfNeeded()
    }

    // MARK: - Actions

    @IBAction private func onEnterPasswordTapped(_ sender: UIButton) {
        initCryptoAccountIfNeeded()
    }

    @IBAction private func onAddressTapped(_ sender: Any) {
        guard let walletAccount = walletAccount else { return }

        UIPasteboard.general.string = walletAccount.publicKey

        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.labelPublicKey.alpha = 0
            self?.labelPublicKey.text = self?.viewModel?.textViewModel.copiedToClipboardText
            self?.labelPublicKey.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 1, animations: { [weak self] in
                self?.labelPublicKey.alpha = 0
                self?.labelPublicKey.text = walletAccount.publicKey
                self?.labelPublicKey.alpha = 1
            })
        })
    }

    @IBAction private func onRequestPaymentTapped(_ sender: UIButton) {
        guard let walletAccount = walletAccount else { return }
        guard let viewModel = viewModel else { return }

        let message = "\(viewModel.textViewModel.requestPaymentMessagePrefix) \(walletAccount.publicKey)"
        let items: [Any] = [message, self]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(viewModel.textViewModel.requestPaymentSubject, forKey: "subject")
        self.present(activityViewController, animated: true)
    }

    // MARK: - Private

    private func initCryptoAccountIfNeeded() {
        guard let viewModel = viewModel else { return }

        walletAccount = nil
        disposable = viewModel.initializeWalletAccount()
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] walletAccount in
                guard let self = self else { return }
                self.walletAccount = walletAccount
            }, onError: { error in
                print("Failed to fetch account.")
            })
    }

    private func initViews() {
        buttonRequestPayment.layer.cornerRadius = 4.0
        buttonRequestPayment.setTitle(viewModel?.textViewModel.requestPaymentText, for: .normal)

        buttonEnterPassword.layer.cornerRadius = 4.0
        buttonEnterPassword.setTitle(viewModel?.textViewModel.enterYourSecondPasswordText, for: .normal)
    }
}
