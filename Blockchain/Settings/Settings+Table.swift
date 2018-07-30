//
//  Settings+Table.swift
//  Blockchain
//
//  Created by Justin on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension SettingsTableViewController {

    enum SettingsCell {
        case base, wallet, email, phoneNumber, currency, recovery, emailNotifications, twoFA, biometry, swipeReceive
    }

    func reloadTableView() {
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case sectionProfile:
            return 4
        case sectionPreferences:
            return 2
        case sectionSecurity:
            var numberOfRows: Int = 6
            if pinBiometry() == -1 {
                numberOfRows -= 1
            }
            if pinSwipeToReceive() == -1 {
                numberOfRows -= 1
            }
            if !WalletManager.shared.wallet.didUpgradeToHd() {
                numberOfRows -= 1
            }
            return numberOfRows
        case aboutSection:
            return 4
        default:
            return 0
        }
    }
    
    func prepareBaseCell(_ cell: UITableViewCell) {
        cell.textLabel?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Medium)
        cell.detailTextLabel?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func prepareBiometryCell(_ cell: UITableViewCell) {
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.selectionStyle = .none
        cell.textLabel?.text = biometryTypeDescription()
        let biometrySwitch = UISwitch()
        let biometryEnabled = BlockchainSettings.sharedAppInstance().biometryEnabled
        biometrySwitch.isOn = biometryEnabled
        biometrySwitch.addTarget(self, action: #selector(self.biometrySwitchTapped), for: .touchUpInside)
        cell.accessoryView = biometrySwitch
    }
    
    func prepareWalletCell(_ cell: UITableViewCell) {
        cell.detailTextLabel?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.ExtraSmall)
        cell.detailTextLabel?.text = WalletManager.shared.wallet.guid
    }
    
    func prepareEmailCell(_ cell: UITableViewCell) {
        getUserEmail() != nil &&
            WalletManager.shared.wallet.getEmailVerifiedStatus() == true ? formatDetailCell(true, cell) : formatDetailCell(false, cell)
    }
    
    func preparePhoneNumberCell(_ cell: UITableViewCell) {
         WalletManager.shared.wallet.hasVerifiedMobileNumber() ? formatDetailCell(true, cell) : formatDetailCell(false, cell)
    }
    
    func prepareCurrencyCell(_ cell: UITableViewCell) {
        let selectedCurrencyCode = getLocalSymbolFromLatestResponse()?.code
        let selectedCurrencySymbol = getLocalSymbolFromLatestResponse()?.symbol
        cell.textLabel?.text = LocalizationConstants.localCurrency
        
        if let selectedCode = selectedCurrencyCode {
            if self.allCurrencySymbolsDictionary[selectedCode] == nil {
                updateAccountInfo()
            }
        }
        
        if selectedCurrencySymbol == nil {
            cell.detailTextLabel?.text = ""
        }
        
        if let currencyCode = selectedCurrencyCode,
            let fiatRepresentable = allCurrencySymbolsDictionary[currencyCode] as? [String: Any] {
            let parsedFiat = FiatCurrency(dictionary: fiatRepresentable)
            cell.detailTextLabel?.text = parsedFiat.description
        }
    }
    
    func prepareSwipeReceiveCell(_ cell: UITableViewCell) {
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        let switchForSwipeToReceive = UISwitch()
        let swipeToReceiveEnabled: Bool = BlockchainSettings.sharedAppInstance().swipeToReceiveEnabled
        switchForSwipeToReceive.isOn = swipeToReceiveEnabled
        switchForSwipeToReceive.addTarget(self, action: #selector(self.switchSwipeToReceiveTapped), for: .touchUpInside)
        cell.accessoryView = switchForSwipeToReceive
    }
    
    func prepare2FACell(_ cell: UITableViewCell) {
        let authType = WalletManager.shared.wallet.getTwoStepType()
        cell.detailTextLabel?.textColor = .green
        if authType == AuthenticationTwoFactorType.sms.rawValue {
            cell.detailTextLabel?.text = "SMS".localized()
        } else if authType == AuthenticationTwoFactorType.google.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.googleAuth
        } else if authType == AuthenticationTwoFactorType.yubiKey.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.yubiKey
        } else if authType == AuthenticationTwoFactorType.none.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.disabled
            cell.detailTextLabel?.textColor = .error
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unknown
        }
    }
    
    func prepareRecoveryCell(_ cell: UITableViewCell) {
        if WalletManager.shared.wallet.isRecoveryPhraseVerified() {
            cell.detailTextLabel?.text = LocalizationConstants.verified
            cell.detailTextLabel?.textColor = .green
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unconfirmed
            cell.detailTextLabel?.textColor = .error
        }
    }
    
    func prepareEmailNotificationsCell(_ cell: UITableViewCell) {
        let switchForEmailNotifications = UISwitch()
        switchForEmailNotifications.isOn = emailNotificationsEnabled()
        switchForEmailNotifications.addTarget(self, action: #selector(self.toggleEmailNotifications), for: .touchUpInside)
        cell.accessoryView = switchForEmailNotifications
    }

    func prepareRow(_ cell: UITableViewCell, _ format: SettingsCell) {
        switch format {
        case .base:
            prepareBaseCell(cell)
        case .biometry:
            prepareBiometryCell(cell)
        case .wallet:
            prepareWalletCell(cell)
        case .email:
           prepareEmailCell(cell)
        case .phoneNumber:
           preparePhoneNumberCell(cell)
        case .currency:
           prepareCurrencyCell(cell)
        case .swipeReceive:
            prepareSwipeReceiveCell(cell)
        case .twoFA:
            prepare2FACell(cell)
        case .recovery:
            prepareRecoveryCell(cell)
        case .emailNotifications:
          prepareEmailNotificationsCell(cell)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {

        prepareRow(cell, .base)
        switch (indexPath.section, indexPath.row) {
        case (sectionProfile, profileWalletIdentifier):
            prepareRow(cell, .wallet)
        case (sectionProfile, profileEmail):
            prepareRow(cell, .email)
        case (sectionProfile, profileMobileNumber):
            prepareRow(cell, .phoneNumber)
        case (sectionPreferences, preferencesEmailNotifications):
            prepareRow(cell, .emailNotifications)
        case (sectionPreferences, preferencesLocalCurrency):
            prepareRow(cell, .currency)
        case (sectionSecurity, securityTwoStep):
            prepareRow(cell, .twoFA)
        case (sectionSecurity, securityWalletRecoveryPhrase):
            prepareRow(cell, .recovery)
        case (sectionSecurity, pinBiometry()):
            prepareRow(cell, .biometry)
        case (sectionSecurity, pinSwipeToReceive()):
            prepareRow(cell, .swipeReceive)
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let headerLabel = UILabel(frame: CGRect(x: 18, y: 12, width:
            tableView.bounds.size.width, height: 45))
        headerLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.SmallMedium)
        headerLabel.textColor = .brandPrimary
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == sectionProfile && indexPath.row == profileWalletIdentifier {
            return indexPath
        }
        let hasLoadedAccountInfoDictionary: Bool = walletManager.wallet.hasLoadedAccountInfo ? true : false
        if !hasLoadedAccountInfoDictionary || (UserDefaults.standard.object(forKey: "loadedSettings") as! Int != 0) == false {
            alertUserOfErrorLoadingSettings()
            return nil
        } else {
            return indexPath
        }
    }
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case sectionProfile:
            switch indexPath.row {
            case profileWalletIdentifier:
                walletIdentifierClicked()
                return
            case profileEmail:
                emailClicked()
                return
            case profileMobileNumber:
                mobileNumberClicked()
                return
            case profileWebLogin:
                webLoginClicked()
                return
            default:
                break
            }
            return
        case sectionPreferences:
            switch indexPath.row {
            case preferencesLocalCurrency:
                performSingleSegue(withIdentifier: "currency", sender: nil)
                return
            default:
                break
            }
            return
        case sectionSecurity:
            if indexPath.row == securityTwoStep {
                showTwoStep()
                return
            } else if indexPath.row == securityPasswordChange {
                changePassword()
                return
            } else if indexPath.row == securityWalletRecoveryPhrase {
                showBackup()
                return
            } else if indexPath.row == PINChangePIN {
                AuthenticationCoordinator.shared.changePin()
                return
            }
            return
        case aboutSection:
            switch indexPath.row {
            case aboutUs:
                aboutUsClicked()
                return
            case aboutTermsOfService:
                termsOfServiceClicked()
                return
            case aboutPrivacyPolicy:
                showPrivacyPolicy()
                return
            case aboutCookiePolicy:
                showCookiePolicy()
                return
            default:
                break
            }
            return
        default:
            break
        }
    }
}
