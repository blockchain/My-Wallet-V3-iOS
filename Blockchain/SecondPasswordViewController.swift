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
        let viewWidth = self.view.frame.size.width
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: Constants.Measurements.DefaultHeaderHeight))
        if #available(iOS 11.0, *) {
            topBar.backgroundColor = UIColor(named: "ColorBrandPrimary")
        } else {
            topBar.backgroundColor = Constants.Colors.ColorBrandPrimary
        }
        self.view.addSubview(topBar)

        let headerLabel = UILabel(frame: CGRect(x: 60, y: 27, width: 200, height: 30))
        headerLabel.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Small)
        headerLabel.textColor = UIColor.white
        headerLabel.textAlignment = .center
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = NSLocalizedString("Second Password Required", comment: "")
        headerLabel.center = CGPoint(x: topBar.center.x, y: headerLabel.center.y)
        topBar.addSubview(headerLabel)

        descriptionLabel.center = CGPoint(x: view.center.x, y: descriptionLabel.center.y)
        descriptionLabel.font = UIFont(name: "GillSans", size: Constants.FontSizes.SmallMedium)
        descriptionLabel.text = NSLocalizedString(
            "This action requires the second password for your wallet. Please enter it below and press continue.",
            comment: "")

        password.center = CGPoint(x: view.center.x, y: password.frame.origin.y)
        password.setupOnePixelLine()
        password.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Small)

        continueButton.center = CGPoint(x: view.center.x, y: continueButton.frame.origin.y)
        continueButton.titleLabel!.font = UIFont(name: "Montserrat-Regular", size: Constants.FontSizes.Large)

        closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: self.view.frame.size.width - 80, y: 15, width: 80, height: 51)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        closeButton.contentHorizontalAlignment = .right
        closeButton.center = CGPoint(x: closeButton.center.x, y: headerLabel.center.y)
        closeButton.setImage(UIImage(named: "close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        topBar.addSubview(closeButton)

        password?.returnKeyType = .done
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
