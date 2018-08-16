//
//  Settings+Table.swift
//  Blockchain
//
//  Created by Justin on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

extension SettingsTableViewController {

    enum SettingsCell {
        case base, identity, wallet, email, phoneNumber, currency, recovery, emailNotifications, twoFA, biometry, swipeReceive
    }

    func reloadTableView() {
        tableView.reloadData()
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
        cell.updateConstraintsIfNeeded()
    }
    
    func prepareWalletCell(_ cell: UITableViewCell) {
        cell.detailTextLabel?.textColor = .brandPrimary
        cell.detailTextLabel?.text = "Copy".localized()
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
        cell.detailTextLabel?.textColor = .brandPrimary
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
        cell.detailTextLabel?.textColor = .white
        createBadge(cell, color: .green)
        if authType == AuthenticationTwoFactorType.sms.rawValue {
            cell.detailTextLabel?.text = "SMS".localized()
        } else if authType == AuthenticationTwoFactorType.google.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.googleAuth
        } else if authType == AuthenticationTwoFactorType.yubiKey.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.Authentication.yubiKey
        } else if authType == AuthenticationTwoFactorType.none.rawValue {
            cell.detailTextLabel?.text = LocalizationConstants.disabled
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .unverified)
        } else {
            createBadge(cell, color: .unverified)
            cell.detailTextLabel?.text = LocalizationConstants.unknown
        }
    }
    
    func prepareRecoveryCell(_ cell: UITableViewCell) {
        if WalletManager.shared.wallet.isRecoveryPhraseVerified() {
            cell.detailTextLabel?.text = LocalizationConstants.verified
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .green)
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unconfirmed
            cell.detailTextLabel?.textColor = .white
            createBadge(cell, color: .unverified)
        }
    }
    
    func prepareEmailNotificationsCell(_ cell: UITableViewCell) {
        let switchForEmailNotifications = UISwitch()
        switchForEmailNotifications.isOn = emailNotificationsEnabled()
        switchForEmailNotifications.addTarget(self, action: #selector(self.toggleEmailNotifications), for: .touchUpInside)
        cell.accessoryView = switchForEmailNotifications
    }

    func getUserVerificationStatus(handler: @escaping (KYCUser?, Bool) -> Void) {
        disposable = BlockchainDataRepository.shared.kycUser
            .subscribeOn(MainScheduler.asyncInstance) // network call will be performed off the main thread
            .observeOn(MainScheduler.instance) // closures passed in subscribe will be on the main thread
            .subscribe(onSuccess: { user in
                handler(user, true)
            }, onError: {  error in
                handler(nil, false)
            })
    }
    
    func prepareIdentityCell(_ cell: UITableViewCell) {
        self.getUserVerificationStatus { status, success in
            if success {
                if let hasDetail = status?.status {
                    let userModel = KYCInformationViewModel.create(for: hasDetail)
                    self.createBadge(cell, status)
                    cell.detailTextLabel?.text = userModel.badge
                }
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
    }
    
    func prepareRow(_ cell: UITableViewCell, _ format: SettingsCell) {
        switch format {
        case .identity:
            prepareIdentityCell(cell)
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
        case (sectionProfile, identityVerification):
            prepareRow(cell, .identity)
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
        case (sectionSecurity, pinBiometry):
            prepareRow(cell, .biometry)
        case (sectionSecurity, pinSwipeToReceive):
            prepareRow(cell, .swipeReceive)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        let headerLabel = UILabel(frame: CGRect(x: 18, y: 3, width:
            tableView.bounds.size.width, height: 32))
        headerLabel.font = UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.ExtraExtraExtraSmall)
        headerLabel.textColor = .gray5
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)

        if section == 0 {
            headerView.frame = CGRect(x: 18, y: 43, width:
                tableView.bounds.size.width, height: 65)
                headerLabel.frame.origin.y += 16
        }
        
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        headerView.layoutIfNeeded()
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         if section == 0 {
                return 50
        }
        return 40
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
            case identityVerification:
                KYCCoordinator().start()
                return
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

class EdgeInsetBadge: EdgeInsetLabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
//        self.centerYAnchor.constraint(equalTo: (superview?.centerYAnchor)!).isActive = true
        self.frame = CGRect(origin: CGPoint(x: 0, y: -50), size: CGSize(width: 60.0, height: 70.0))
    }
    
    @IBInspectable
    var background: UIColor {
        set { self.backgroundColor = newValue }
        get { return backgroundColor ?? .green }
    }
}

class EdgeInsetLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}

//class customRightDetailText: UITableViewCell {
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//    
//    override init(style: UITableViewCellStyle,
//         reuseIdentifier: String?) {
//        super.init(style: .value2, reuseIdentifier:reuseIdentifier)
//        commonInit()
//    }
//    
//    func commonInit() {
//        self.detailTextLabel?.frame = CGRect(origin: CGPoint(x: 0, y: -50), size: CGSize(width: 60.0, height: 70.0))
//    }
//}
