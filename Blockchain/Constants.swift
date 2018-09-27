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
        static let satoshi = UInt64(1e8)
    }

    struct AppStore {
        static let AppID = "id493253309"
    }
    struct Animation {
        static let duration = 0.2
        static let durationLong = 0.5
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
        static let modalViewDismissed = NSNotification.Name("modalViewDismissed")
        static let reloadToDismissViews = NSNotification.Name("reloadToDismissViews")
        static let newAddress = NSNotification.Name("newAddress")
        static let multiAddressResponseReload = NSNotification.Name("multiaddressResponseReload")
        static let appEnteredBackground = NSNotification.Name("applicationDidEnterBackground")
        static let backupSuccess = NSNotification.Name("backupSuccess")
        static let getFiatAtTime = NSNotification.Name("getFiatAtTime")
        static let exchangeSubmitted = NSNotification.Name("exchangeSubmitted")
    }
    struct PushNotificationKeys {
        static let userInfoType = "type"
        static let userInfoId = "id"
        static let typePayment = "payment"
    }
    struct Schemes {
        static let bitcoin = "bitcoin"
        static let bitcoinCash = "bitcoincash"
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
        static let forgotPassword = "https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
    }
    struct Wallet {
        static let swipeToReceiveAddressCount = 5
    }
    struct JSErrors {
        static let addressAndKeyImportWrongBipPass = "wrongBipPass"
        static let addressAndKeyImportWrongPrivateKey = "wrongPrivateKey"
    }
}

/// Constant class wrapper so that Constants can be accessed from Obj-C. Should deprecate this
/// once Obj-C is no longer using this
@objc class ConstantsObjcBridge: NSObject {
    @objc class func animationDuration() -> Double { return Constants.Animation.duration }

    @objc class func animationDurationLong() -> Double { return Constants.Animation.durationLong }

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
}
