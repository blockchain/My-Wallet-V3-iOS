//
//  NabuNetworkError.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Describes an error returned by Nabu
struct NabuNetworkError: Codable, Error {
    let code: NabuNetworkErrorCode
    let type: NabuNetworkErrorType
    let description: String
}

enum NabuNetworkErrorCode: Int, Codable {

    // Generic HTTP errors
    case internalServerError = 1
    case notFound = 2
    case badMethod = 3
    case conflict = 4

    // generic user input errors
    case missingBody = 5
    case missingParam = 6
    case badParamValue = 7

    // authentication errors
    case invalidCredentials = 8
    case wrongPassword = 9
    case wrong2fa = 10
    case bad2fa = 11
    case unknownUser = 12
    case invalidRole = 13
    case alreadyLoggedIn = 14
    case invalidStatus = 15

    // currency ratio errors
    case notSupportedCurrencyPair = 16
    case unknownCurrencyPair = 17
    case unknownCurrency = 18
    case currencyIsNotFiat = 19
    case tooSmallVolume = 26
    case tooBigVolume = 27
    case resultCurrencyRatioTooSmall = 28

    // conversion errors
    case providedVolumeIsNotDouble = 20
    case unknownConversionType = 21

    // kyc errors
    case userNotActive = 22
    case pendingKycReview = 23
    case kycAlreadyCompleted = 24
    case maxKycAttempts = 25
    case invalidCountryCode = 29

    // user-onboarding errors
    case invalidJwtToken = 30
    case expiredJwtToken = 31
    case mobileRegisteredAlready = 32
    case userRegisteredAlready = 33
    case missingApiToken = 34
    case couldNotInsertUser = 35
    case userRestored = 36

    // user trading error
    case genericTradingError = 37
    case albertExecutionError = 38
    case userHasNoCountry = 39
    case userNotFound = 40
    case orderBelowMinLimit = 41
    case wrongDepositAmount = 42
    case orderAboveMaxLimit = 43
    case ratesApiError = 44
    case dailyLimitExceeded = 45
    case weeklyLimitExceeded = 46
    case annualLimitExceeded = 47
    case notCryptoToCryptoCurrencyPair = 48
}

enum NabuNetworkErrorType: String, Codable {

    // Generic HTTP errors
    case internalServerError = "INTERNAL_SERVER_ERROR"
    case notFound = "NOT_FOUND"
    case badMethod = "BAD_METHOD"
    case conflict = "CONFLICT"

    // Generic user input errors
    case missingBody = "MISSING_BODY"
    case missinParam = "MISSING_PARAM"
    case badParamValue = "BAD_PARAM_VALUE"

    // Authentication errors
    case invalidCredentials = "INVALID_CREDENTIALS"
    case wrongPassword = "WRONG_PASSWORD"
    case wrong2FA = "WRONG_2FA"
    case bad2FA = "BAD_2FA"
    case unknownUser = "UNKNOWN_USER"
    case invalidRole = "INVALID_ROLE"
    case alreadyLoggedIn = "ALREADY_LOGGED_IN"
    case invalidStatus = "INVALID_STATUS"
}
