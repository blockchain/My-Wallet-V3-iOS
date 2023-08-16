// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum HttpHeaderField {
    public static let userAgent = "User-Agent"
    public static let accept = "Accept"
    public static let acceptLanguage = "Accept-Language"
    public static let contentLength = "Content-Length"
    public static let contentType = "Content-Type"
    public static let appVersion = "X-APP-VERSION"
    public static let clientType = "X-CLIENT-TYPE"
    public static let walletGuid = "X-WALLET-GUID"
    public static let walletEmail = "X-WALLET-EMAIL"
    public static let deviceId = "X-DEVICE-ID"
    public static let requestId = "X-Request-ID"
    public static let airdropCampaign = "X-CAMPAIGN"
    public static let blockchainOrigin = "blockchain-origin"
    public static let authorization = "Authorization"
    public static let bitpayPartner = "BP_PARTNER"
    public static let bitpayPartnerVersion = "BP_PARTNER_VERSION"
    public static let xPayProVersion = "x-paypro-version"
    public static let origin = "Origin"
}

public enum HttpHeaderValue {
    public static let json = "application/json"
    public static let bitpayPaymentOptions = "application/payment-options"
    public static let bitpayPaymentRequest = "application/payment-request"
    public static let bitpayPaymentVerification = "application/payment-verification"
    public static let bitpayPayment = "application/payment"
    public static let bitpayPartnerName = "Blockchain"
    public static let bitpayPartnerVersion = "V6.28.0"
    public static let xPayProVersion = "2"
    public static let formEncoded = "application/x-www-form-urlencoded"
    public static let clientTypeApp = "APP"
    public static let simpleBuy = "simplebuy"
    public static let externalBrokerage = "EXTERNAL_BROKERAGE"
}
