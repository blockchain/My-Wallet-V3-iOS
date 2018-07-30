//
//  SecondPasswordViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 18-06-15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

protocol SecondPasswordDelegate: class {
    func didGetSecondPassword(_: String)
    func returnToRootViewController(_ completionHandler: @escaping () -> Void)
    var isVerifying: Bool { get set }
}

class SecondPasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var password: BCSecureTextField!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!

    var topBar: UIView!
    var closeButton: UIButton!
    var wallet: Wallet?
    weak var delegate: SecondPasswordDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = UIView.rootViewSafeAreaFrame(navigationBar: true, tabBar: false, assetSelector: false)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(close)
        )

        descriptionLabel.font = UIFont(name: "GillSans", size: Constants.FontSizes.SmallMedium)
        descriptionLabel.text = NSLocalizedString(
            "This action requires the second password for your wallet. Please enter it below and press continue.",
            comment: "")

        password.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Small)
        password.returnKeyType = .done

        continueButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Large)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        password.setupOnePixelLine()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        password?.becomeFirstResponder()
    }

    @IBAction func done(_ sender: UIButton) {
        checkSecondPassword()
    }

    @IBAction func close(_ sender: UIButton) {
        password?.resignFirstResponder()
        delegate!.returnToRootViewController { () -> Void in
            self.dismiss(animated: true, completion: nil)
        }
    }

    func checkSecondPassword() {
        let secondPassword = password.text
        if secondPassword!.isEmpty {
            alertUserWithErrorMessage((NSLocalizedString("No Password Entered", comment: "")))
        } else if wallet!.validateSecondPassword(secondPassword) {
            password?.resignFirstResponder()
            delegate?.didGetSecondPassword(secondPassword!)
            if delegate!.isVerifying {
                // if we are verifying backup, go to verify words view controller
                self.navigationController?.performSegue(withIdentifier: "backupVerify", sender: nil)
            }
			self.dismiss(animated: true, completion: nil)
        } else {
            alertUserWithErrorMessage((NSLocalizedString("Second Password Incorrect", comment: "")))
        }
    }

    func alertUserWithErrorMessage(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Error", comment: ""),
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { _ in
             self.password?.text = ""
        }))
        NotificationCenter.default.addObserver(
            alert,
            selector: #selector(UIViewController.autoDismiss),
            name: NSNotification.Name(rawValue: "reloadToDismissViews"),
            object: nil)
        present(alert, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkSecondPassword()
        return true
    }
}
