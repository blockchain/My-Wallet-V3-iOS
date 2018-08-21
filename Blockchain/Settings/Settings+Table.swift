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
        var authService: NetworkClient!
        var url = URLComponents(string: BlockchainAPI.shared.retailCoreUrl)!
        authService = NetworkClient(session: URLSession.shared)
        let authFuture = CompletableFuture<NetworkClient>()

        url.path = "/nabu-app/internal/auth"
        url.queryItems = [
            URLQueryItem(name: "userId", value: WalletManager.shared.wallet.kycUserId())
        ]
    //   var url = URL(string: BlockchainAPI.shared.retailCoreUrl)!
   //     url.appendPathComponent("/internal/auth")
        
        var req = URLRequest(url: url.url!)
        req.httpMethod = "POST"
        req.httpBody = nil
   //     req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue("APP", forHTTPHeaderField: "X-CLIENT-TYPE")
        req.addValue("389ufd89y7ery798347efu89", forHTTPHeaderField: "X-DEVICE-ID")
        req.addValue("7050fc43-ec01-462a-be7c-8880e1701fce", forHTTPHeaderField: "authorization")
        req.addValue("aa8cca2e-fb67-43fc-9965-1d42768adca8", forHTTPHeaderField: "X-WALLET-GUID")
        req.addValue("6.11.1", forHTTPHeaderField: "X-APP-VERSION")
        
        
        authFuture.then { (client: NetworkClient) in
            print("lets try", client)
        }

//        authService.getAndParse(request: req, model: KYCApiTokenResponse.self) { result in
//            switch result {
//            case .success(let model):
//                print("did we get it?", model)
//                authFuture.complete(value: self.authService)
//            case .failure(let error):
//                Logger.shared.error("Failed to parse model without promise: \(error.localizedDescription)")
//                break
//            }
//        }
        
        authFuture.then { (client: NetworkClient) in
            
            client.getAndParse(request: req, model: KYCApiTokenResponse.self) { result in
                switch result {
                case .success(let model):
                    print("did we get it?", model)
                    authFuture.complete(value: authService)
                case .failure(let error):
                    Logger.shared.error("Failed to parse model in then: \(error.localizedDescription)")
                    break
                }
            }
            }.then { (client) in
                print("got here!")
        }
        

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
        self.createBadge(cell, color: .clear)
        self.getUserVerificationStatus { status, success in
            if success {
                if let hasDetail = status?.status {
                    let userModel = KYCInformationViewModel.create(for: hasDetail)
                    self.createBadge(cell, status)
                    cell.detailTextLabel?.text = userModel.badge
                }
            } else if !success {
                self.createBadge(cell, color: .unverified)
                cell.detailTextLabel?.text = LocalizationConstants.KYC.accountUnverifiedBadge
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func prepareRow(_ cell: UITableViewCell, _ format: SettingsCell) {
        switch format {
        case .identity: prepareIdentityCell(cell)
        case .base: prepareBaseCell(cell)
        case .biometry: prepareBiometryCell(cell)
        case .wallet: prepareWalletCell(cell)
        case .email: prepareEmailCell(cell)
        case .phoneNumber: preparePhoneNumberCell(cell)
        case .currency: prepareCurrencyCell(cell)
        case .swipeReceive: prepareSwipeReceiveCell(cell)
        case .twoFA: prepare2FACell(cell)
        case .recovery: prepareRecoveryCell(cell)
        case .emailNotifications: prepareEmailNotificationsCell(cell)
        }
    }

    // MARK: - UITableViewDelegate

    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        prepareRow(cell, .base)
        switch (indexPath.section, indexPath.row) {
        case (sectionProfile, identityVerification): self.prepareRow(cell, .identity)
        case (sectionProfile, profileWalletIdentifier): prepareRow(cell, .wallet)
        case (sectionProfile, profileEmail): prepareRow(cell, .email)
        case (sectionProfile, profileMobileNumber): prepareRow(cell, .phoneNumber)
        case (sectionPreferences, preferencesEmailNotifications): prepareRow(cell, .emailNotifications)
        case (sectionPreferences, preferencesLocalCurrency): prepareRow(cell, .currency)
        case (sectionSecurity, securityTwoStep): prepareRow(cell, .twoFA)
        case (sectionSecurity, securityWalletRecoveryPhrase): prepareRow(cell, .recovery)
        case (sectionSecurity, pinBiometry): prepareRow(cell, .biometry)
        case (sectionSecurity, pinSwipeToReceive): prepareRow(cell, .swipeReceive)
        default: break

        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = SettingsTableSectionHeader.fromNib() as SettingsTableSectionHeader
        sectionHeaderView.label.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        return sectionHeaderView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
    // swiftlint:disable:next cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case sectionProfile:
            switch indexPath.row {
            case identityVerification: KYCCoordinator().embed()
            case profileWalletIdentifier: walletIdentifierClicked()
            case profileEmail: emailClicked()
            case profileMobileNumber: mobileNumberClicked()
            case profileWebLogin: webLoginClicked()
            default: return
            }
        case sectionPreferences:
            switch indexPath.row {
            case preferencesLocalCurrency:
                performSingleSegue(withIdentifier: "currency", sender: nil)
            default: return
            }
        case sectionSecurity:
            if indexPath.row == securityTwoStep {
                showTwoStep()
            } else if indexPath.row == securityPasswordChange {
                changePassword()
            } else if indexPath.row == securityWalletRecoveryPhrase {
                showBackup()
            } else if indexPath.row == PINChangePIN {
                AuthenticationCoordinator.shared.changePin()
            }
        case aboutSection:
            switch indexPath.row {
            case aboutUs: aboutUsClicked()
            case aboutTermsOfService: termsOfServiceClicked()
            case aboutPrivacyPolicy: showPrivacyPolicy()
            case aboutCookiePolicy: showCookiePolicy()
            default: return
            }
        default: return
        }
    }
}

class EdgeInsetBadge: EdgeInsetLabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        sizeToFit()
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
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
