//
//  Constants.swift
//  Blockchain
//
//  Created by Mark Pfluger on 6/26/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

struct Constants {

    struct Conversions {
        // SATOSHI = 1e8 (100,000,000)
        static let satoshi = Double(1e8)

        /// Stroop is a measurement of 1/10,000,000th of an XLM
        static let stroopsInXlm = Int(1e7)
    }

    struct AppStore {
        static let AppID = "id493253309"
    }
    struct Animation {
        static let duration = 0.2
        static let durationLong = 0.5
    }
    struct Navigation {
        static let tabTransactions = 0
        static let tabSwap = 1
        static let tabDashboard = 2
        static let tabSend = 3
        static let tabReceive = 4
    }
    struct TransactionTypes {
        // TODO: change to enum, move to its own file,
        // and deprecate TX_TYPE_* in Blockchain-Prefix
        static let sent = "sent"
        static let receive = "received"
        static let transfer = "transfer"
    }
    struct Measurements {
        static let DefaultHeaderHeight: CGFloat = 65
        // TODO: remove this once we use autolayout
        static let DefaultStatusBarHeight: CGFloat = 20.0
        static let DefaultNavigationBarHeight: CGFloat = 44.0
        static let DefaultTabBarHeight: CGFloat = 49.0
        static let AssetSelectorHeight: CGFloat = 36.0
        static let BackupButtonCornerRadius: CGFloat = 4.0
        static let BusyViewLabelWidth: CGFloat = 230.0
        static let BusyViewLabelHeight: CGFloat = 30.0
        static let BusyViewLabelAlpha: CGFloat = 0.75
        static let BusyViewLabelFontSystemSize: CGFloat = 14.0

        static let ScreenHeightIphone4S: CGFloat = 480.0
        static let ScreenHeightIphone5S: CGFloat = 568.0

        static let MinimumTapTargetSize: CGFloat = 22.0

        static let infoLabelEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 9.5, bottom: 2, right: 9.5)
        static let buttonHeight: CGFloat = 40.0
        static let buttonCornerRadius: CGFloat = 4.0
        static let assetTypeCellHeight: CGFloat = 44.0
    }
    struct FontSizes {
        static let Tiny: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 11.0 : 10.0
        static let ExtraExtraExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 13.0 : 11.0
        static let ExtraExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 14.0 : 11.0
        static let ExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 15.0 : 12.0
        static let Small: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 16.0 : 13.0
        static let SmallMedium: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 17.0 : 14.0
        static let Medium: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 18.0 : 15.0
        static let MediumLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 19.0 : 16.0
        static let Large: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 20.0 : 17.0
        static let ExtraLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 21.0 : 18.0
        static let ExtraExtraLarge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 23.0 : 20.0
        static let Huge: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 25.0 : 22.0
        static let Gigantic: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 48.0 : 45.0
    }
    struct FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratSemiBold = "Montserrat-SemiBold"
        static let montserratLight = "Montserrat-Light"
        static let montserratMedium = "Montserrat-Medium"
        static let montserratSemiExtraLight = "Montserrat-ExtraLight"
        static let gillSans = "GillSans"
        static let gillSansLight = "GillSans-Light"
        static let helveticaNueue = "Helvetica Neue"
        static let helveticaNueueMedium = "HelveticaNeue-Medium"
    }
    struct Defaults {
        static let NumberOfRecoveryPhraseWords = 12
    }
    struct Booleans {
        static let IsUsingScreenSizeLargerThan5s = UIScreen.main.bounds.size.height > Measurements.ScreenHeightIphone5S
    }
    struct NotificationKeys {
        static let walletSetupViewControllerDismissed = NSNotification.Name("walletSetupDismissed")
        static let modalViewDismissed = NSNotification.Name("modalViewDismissed")
        static let reloadToDismissViews = NSNotification.Name("reloadToDismissViews")
        static let newAddress = NSNotification.Name("newAddress")
        static let multiAddressResponseReload = NSNotification.Name("multiaddressResponseReload")
        static let appEnteredBackground = NSNotification.Name("applicationDidEnterBackground")
        static let backupSuccess = NSNotification.Name("backupSuccess")
        static let getFiatAtTime = NSNotification.Name("getFiatAtTime")
        static let exchangeSubmitted = NSNotification.Name("exchangeSubmitted")
        static let transactionReceived = NSNotification.Name("transactionReceived")
        static let kycStopped = NSNotification.Name("kycStopped")
        static let swapFlowCompleted = NSNotification.Name("swapFlowCompleted")
        static let swapToPaxFlowCompleted = NSNotification.Name("swapToPaxFlowCompleted")
    }
    struct PushNotificationKeys {
        static let userInfoType = "type"
        static let userInfoId = "id"
        static let typePayment = "payment"
    }
    struct Schemes {
        static let bitcoin = "bitcoin"
        static let bitcoinCash = "bitcoincash"
        static let stellar = "web+stellar"
        static let blockchain = "blockchain"
        static let blockchainWallet = "blockchain-wallet"
        static let ethereum = "ethereum"
        static let mail = "message"
    }
    struct Security {
        static let pinPBKDF2Iterations = 1 // This does not need to be large because the key is already 256 bits
    }
    struct Time {
        static let securityReminderModalTimeInterval: TimeInterval = 60 * 60 * 24 * 30 // Seconds in thirty days
    }
    struct Locales {
        static let englishUS = "en_US"
    }
    struct Url {
        static let blockchainHome = "https://www.blockchain.com"
        static let privacyPolicy = blockchainHome + "/privacy"
        static let termsOfService = blockchainHome + "/terms"
        static let cookiePolicy = blockchainHome + "/cookies"
        static let appStoreLinkPrefix = "itms-apps://itunes.apple.com/app/"
        static let blockchainSupport = "https://support.blockchain.com"
        static let verificationRejectedURL = "https://support.blockchain.com/hc/en-us/articles/360018080352-Why-has-my-ID-submission-been-rejected-"
        static let blockchainSupportRequest = blockchainSupport + "/hc/en-us/requests/new?"
        static let supportTicketBuySellExchange = blockchainSupportRequest + "ticket_form_id=360000014686"
        static let forgotPassword = "https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
        static let blockchainWalletLogin = "https://login.blockchain.com"
        static let lockbox = "https://blockchain.com/lockbox"
        static let stellarMinimumBalanceInfo = "https://www.stellar.org/developers/guides/concepts/fees.html#minimum-account-balance"
        static let airdropProgram = "https://support.blockchain.com/hc/en-us/categories/360001126692-Airdrop-Program"
        static let airdropWaitlist = blockchainHome + "/getcrypto"
        static let requiredIdentityVerificationURL = "https://support.blockchain.com/hc/en-us/articles/360018359871-What-Blockchain-products-require-identity-verification-"
        static let learnMoreAboutPaxURL = "https://support.blockchain.com/hc/en-us/sections/360004368351-USD-Pax-FAQ"
        static let ethGasExplanationForPax = "https://support.blockchain.com/hc/en-us/articles/360027492092-Why-do-I-need-ETH-to-send-my-PAX-"
    }
    struct Wallet {
        static let swipeToReceiveAddressCount = 5
    }
    struct JSErrors {
        static let addressAndKeyImportWrongBipPass = "wrongBipPass"
        static let addressAndKeyImportWrongPrivateKey = "wrongPrivateKey"
    }
    struct AssetTypeCodes {
        static let bitcoin = "BTC"
        static let ethereum = "ETH"
        static let bitcoinCash = "BCH"
    }
    struct FilterIndexes {
        static let all: Int32 = -1
        static let importedAddresses: Int32 = -2
    }
}

/// Constant class wrapper so that Constants can be accessed from Obj-C. Should deprecate this
/// once Obj-C is no longer using this
@objc class ConstantsObjcBridge: NSObject {
    @objc class func airdropWaitlistUrl() -> String { return Constants.Url.airdropWaitlist }

    @objc class func animationDuration() -> Double { return Constants.Animation.duration }

    @objc class func animationDurationLong() -> Double { return Constants.Animation.durationLong }
    
    @objc class func walletSetupDismissedNotification() -> String {
        return Constants.NotificationKeys.walletSetupViewControllerDismissed.rawValue
    }

    @objc class func notificationKeyModalViewDismissed() -> String {
        return Constants.NotificationKeys.modalViewDismissed.rawValue
    }

    @objc class func notificationKeyReloadToDismissViews() -> String {
        return Constants.NotificationKeys.reloadToDismissViews.rawValue
    }

    @objc class func notificationKeyNewAddress() -> String {
        return Constants.NotificationKeys.newAddress.rawValue
    }

    @objc class func notificationKeyMultiAddressResponseReload() -> String {
        return Constants.NotificationKeys.multiAddressResponseReload.rawValue
    }

    @objc class func notificationKeyBackupSuccess() -> String {
        return Constants.NotificationKeys.backupSuccess.rawValue
    }

    @objc class func notificationKeyGetFiatAtTime() -> String {
        return Constants.NotificationKeys.getFiatAtTime.rawValue
    }
    
    @objc class func notificationKeyTransactionReceived() -> String {
        return Constants.NotificationKeys.transactionReceived.rawValue
    }
    
    @objc class func tabSwap() -> Int {
        return Constants.Navigation.tabSwap
    }

    @objc class func tabSend() -> Int {
        return Constants.Navigation.tabSend
    }

    @objc class func tabDashboard() -> Int {
        return Constants.Navigation.tabDashboard
    }

    @objc class func tabReceive() -> Int {
        return Constants.Navigation.tabReceive
    }

    @objc class func tabTransactions() -> Int {
        return Constants.Navigation.tabTransactions
    }

    @objc class func filterIndexAll() -> Int32 {
        return Constants.FilterIndexes.all
    }

    @objc class func filterIndexImportedAddresses() -> Int32 {
        return Constants.FilterIndexes.importedAddresses
    }

    @objc class func assetTypeCellHeight() -> CGFloat {
        return Constants.Measurements.assetTypeCellHeight
    }

    @objc class func bitcoinUriPrefix() -> String {
        return Constants.Schemes.bitcoin
    }

    @objc class func bitcoinCashUriPrefix() -> String {
        return Constants.Schemes.bitcoinCash
    }

    @objc class func ethereumUriPrefix() -> String {
        return Constants.Schemes.ethereum
    }

    @objc class func wrongPrivateKey() -> String {
        return Constants.JSErrors.addressAndKeyImportWrongPrivateKey
    }

    @objc class func wrongBip38Password() -> String {
        return Constants.JSErrors.addressAndKeyImportWrongBipPass
    }

    @objc class func termsOfServiceURLString() -> String {
        return Constants.Url.termsOfService
    }

    @objc class func privacyPolicyURLString() -> String {
        return Constants.Url.privacyPolicy
    }

    @objc class func cookiePolicyURLString() -> String {
        return Constants.Url.cookiePolicy
    }

    @objc class func defaultNavigationBarHeight() -> CGFloat {
        return Constants.Measurements.DefaultNavigationBarHeight
    }

    @objc class func assetSelectorHeight() -> CGFloat {
        return Constants.Measurements.AssetSelectorHeight
    }

    @objc class func minimumTapTargetSize() -> CGFloat {
        return Constants.Measurements.MinimumTapTargetSize
    }

    @objc class func montserratLight() -> String {
        return Constants.FontNames.montserratLight
    }

    @objc class func montserratSemiBold() -> String {
        return Constants.FontNames.montserratSemiBold
    }

    @objc class func infoLabelEdgeInsets() -> UIEdgeInsets {
        return Constants.Measurements.infoLabelEdgeInsets
    }

    @objc class func btcCode() -> String {
        return Constants.AssetTypeCodes.bitcoin
    }
}
