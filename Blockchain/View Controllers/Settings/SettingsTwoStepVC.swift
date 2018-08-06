//
//  SettingsTwoStepVC.swift
//  Blockchain
//
//  Created by Justin on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SettingsTwoSteps {
    var titleLabel: UILabel! { get set }
    var twoStepButton: UIButton! { get set }
    var settingsController: SettingsTableViewController! { get set }
    func updateUI()
}

@objc class SettingsTwoStepViewController: UIViewController, SettingsTwoSteps {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var twoStepButton: UIButton!
    var settingsController: SettingsTableViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        twoStepButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        twoStepButton.titleLabel?.adjustsFontSizeToFitWidth = true
        twoStepButton.titleLabel?.textAlignment = .center
        if let buttonFont = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Large) {
            twoStepButton.titleLabel?.font = buttonFont
        }
        titleLabel.font = UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Large)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationController = self.navigationController as? SettingsNavigationController
        navigationController?.headerLabel.text = LocalizationConstants.twostep
        updateUI()
    }
    func updateUI() {
        WalletManager.shared.wallet.hasEnabledTwoStep() ?
            twoStepButton.setTitle("Disable".localized(), for: .normal) : twoStepButton.setTitle("Enable 2-Step for SMS".localized(), for: .normal)
    }
    @IBAction func twoStepTapped(_ sender: UIButton) {
        settingsController?.changeTwoStepTapped()
    }
}
