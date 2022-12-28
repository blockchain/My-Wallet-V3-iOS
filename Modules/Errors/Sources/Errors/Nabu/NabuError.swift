// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding
import Extensions
import Foundation

public typealias NabuNetworkError = Nabu.Error
public typealias NabuError = Nabu.Error
public typealias NabuErrorCode = Nabu.ErrorCode
public typealias NabuErrorType = Nabu.ErrorType

public enum Nabu {

    public struct Error: Swift.Error, Equatable, Hashable {

        public var id: String
        public var code: ErrorCode
        public var type: ErrorType
        public var description: String?
        public var ux: UX.Dialog?

        public var request: URLRequest?
        public var response: HTTPURLResponse?

        public init(
            id: String,
            code: Nabu.ErrorCode,
            type: Nabu.ErrorType,
            description: String? = nil,
            ux: UX.Dialog? = nil,
            request: URLRequest? = nil,
            response: HTTPURLResponse? = nil
        ) {
            self.id = id
            self.code = code
            self.type = type
            self.description = description
            self.ux = ux
            self.request = request
            self.response = response
        }
    }

    public struct ErrorType: RawRepresentable, Equatable, Hashable, Codable {

        public var rawValue: String

        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public struct ErrorCode: RawRepresentable, Equatable, Hashable, Codable {

        public var rawValue: UInt

        public init?(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}

extension Nabu.Error: FromNetworkErrorConvertible {

    public static let network: String = "network"
    public static let unknown = Nabu.Error(id: "MISSING", code: .unknown, type: .unknown)

    public static func from(_ networkError: NetworkError) -> Nabu.Error {
        do {
            let payload = networkError.payload.or(default: Data())
            return try AnyDecoder(
                userInfo: [
                    .networkURLRequest: networkError.request as Any,
                    .networkHTTPResponse: networkError.response as Any
                ]
            ).decode(Nabu.Error.self, from: JSONSerialization.jsonObject(with: payload))
        } catch {
            return Nabu.Error(
                id: Nabu.Error.network,
                code: networkError.code.map(UInt.init).map(Nabu.ErrorCode.init(_:)) ?? .unknown,
                type: .unknown,
                description: networkError.description,
                ux: nil,
                request: networkError.request,
                response: networkError.response
            )
        }
    }
}

extension Nabu.Error: Codable {

    public init(from decoder: Decoder) throws {
        self = try JSON(from: decoder)
            .decode(
                request: decoder.userInfo[.networkURLRequest] as? URLRequest,
                response: decoder.userInfo[.networkHTTPResponse] as? HTTPURLResponse
            )
    }

    public func encode(to encoder: Encoder) throws {
        try json.encode(to: encoder)
    }

    var json: JSON {
        .init(
            id: id,
            code: code,
            type: type,
            description: description,
            ux: ux
        )
    }

    struct JSON: Equatable, Hashable, Codable {
        let id: String
        let code: Nabu.ErrorCode
        let type: Nabu.ErrorType
        let description: String?
        let ux: UX.Dialog?
    }
}

extension Nabu.Error.JSON {

    func decode(request: URLRequest?, response: HTTPURLResponse?) -> Nabu.Error {
        .init(
            id: id,
            code: code,
            type: type,
            description: description,
            ux: ux,
            request: request,
            response: response
        )
    }
}

extension Nabu.ErrorType {

    public init(from decoder: Decoder) throws {
        rawValue = try String(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Nabu.ErrorType {

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static let unknown = Self("UNKNOWN")

    public static let internalServerError = Self("INTERNAL_SERVER_ERROR")
    public static let notFound = Self("NOT_FOUND")
    public static let badMethod = Self("BAD_METHOD")
    public static let badRequest = Self("BAD_REQUEST")
    public static let conflict = Self("CONFLICT")
    public static let notAcceptable = Self("NOT_ACCEPTABLE")
    public static let missingBody = Self("MISSING_BODY")
    public static let missingParameter = Self("MISSING_PARAM")
    public static let badParameterValue = Self("BAD_PARAM_VALUE")
    public static let forbidden = Self("FORBIDDEN")
    public static let invalidCredentials = Self("INVALID_CREDENTIALS")
    public static let wrongPassword = Self("WRONG_PASSWORD")
    public static let wrong2FA = Self("WRONG_2FA")
    public static let bad2FA = Self("BAD_2FA")
    public static let unknownUser = Self("UNKNOWN_USER")
    public static let invalidRole = Self("INVALID_ROLE")
    public static let alreadyLoggedIn = Self("ALREADY_LOGGED_IN")
    public static let invalidStatus = Self("INVALID_STATUS")
    public static let missingTradePermissions = Self("NO_TRADE_PERMISSION")
}

extension Nabu.ErrorCode {

    public init(from decoder: Decoder) throws {
        rawValue = try UInt(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension Nabu.ErrorCode {

    public init(_ rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let unknown = Self(UInt.max)

    public static let internalServerError = Self(1)
    public static let notFound = Self(2)
    public static let badMethod = Self(3)
    public static let conflict = Self(4)
    public static let missingBody = Self(5)
    public static let missingParam = Self(6)
    public static let badParamValue = Self(7)
    public static let invalidCredentials = Self(8)
    public static let wrongPassword = Self(9)
    public static let wrong2fa = Self(10)
    public static let bad2fa = Self(11)
    public static let unknownUser = Self(12)
    public static let invalidRole = Self(13)
    public static let alreadyLoggedIn = Self(14)
    public static let invalidStatus = Self(15)
    public static let notSupportedCurrencyPair = Self(16)
    public static let unknownCurrencyPair = Self(17)
    public static let unknownCurrency = Self(18)
    public static let currencyIsNotFiat = Self(19)
    public static let tooSmallVolume = Self(26)
    public static let tooBigVolume = Self(27)
    public static let resultCurrencyRatioTooSmall = Self(28)
    public static let providedVolumeIsNotDouble = Self(20)
    public static let unknownConversionType = Self(21)
    public static let userNotActive = Self(22)
    public static let pendingKycReview = Self(23)
    public static let kycAlreadyCompleted = Self(24)
    public static let maxKycAttempts = Self(25)
    public static let invalidCountryCode = Self(29)
    public static let invalidJwtToken = Self(30)
    public static let expiredJwtToken = Self(31)
    public static let mobileRegisteredAlready = Self(32)
    public static let userRegisteredAlready = Self(33)
    public static let missingApiToken = Self(34)
    public static let couldNotInsertUser = Self(35)
    public static let userRestored = Self(36)
    public static let genericTradingError = Self(37)
    public static let albertExecutionError = Self(38)
    public static let userHasNoCountry = Self(39)
    public static let userNotFound = Self(40)
    public static let orderBelowMinLimit = Self(41)
    public static let wrongDepositAmount = Self(42)
    public static let orderAboveMaxLimit = Self(43)
    public static let ratesApiError = Self(44)
    public static let dailyLimitExceeded = Self(45)
    public static let weeklyLimitExceeded = Self(46)
    public static let annualLimitExceeded = Self(47)
    public static let notCryptoToCryptoCurrencyPair = Self(48)
    public static let invalidCountryStateCode = Self(49)
    public static let blockedPhone = Self(50)
    public static let pendingOrdersLimitReached = Self(53)
    public static let tradingDisabled = Self(51)
    public static let mobileTooLong = Self(52)
    public static let invalidCampaign = Self(54)
    public static let invalidCampaignUser = Self(55)
    public static let campaignUserAlreadyRegistered = Self(56)
    public static let campaignExpired = Self(57)
    public static let invalidCampaignInfo = Self(58)
    public static let campaignWithdrawalFailed = Self(59)
    public static let tradeForceExecuteError = Self(60)
    public static let campaignInfoAlreadyUsed = Self(61)
    public static let linkAccountError = Self(66)
    public static let userAlreadyLinked = Self(660)
    public static let linkExpired = Self(661)
    public static let verificationExpired = Self(63)
    public static let verificationFailed = Self(64)
    public static let emailVerificationInProgress = Self(65)
    public static let userHasNoUsername = Self(67)
    public static let noAvailableUsername = Self(680)
    public static let userNotAllowedToGetCredentials = Self(70)
    public static let enablementFailed = Self(69)
    public static let depositCheckError = Self(72)
    public static let couldNotInsertBeneficiary = Self(74)
    public static let beneficiaryAlreadyExists = Self(75)
    public static let beneficiaryNotFound = Self(76)
    public static let paymentsNotSupported = Self(77)
    public static let productNotSpecified = Self(78)
    public static let notAuthorizedForFiat = Self(79)
    public static let missingCryptoAddress = Self(87)
    public static let missingBeneficiary = Self(88)
    public static let invalidWithdrawalAmount = Self(90)
    public static let exchangeRateFetchFailure = Self(91)
    public static let minimumWithdrawalAmount = Self(92)
    public static let invalidCryptoAddress = Self(93)
    public static let invalidCryptoCurrency = Self(94)
    public static let tierTooLow = Self(98)
    public static let invalidAddress = Self(99)
    public static let invalidPostcode = Self(158)
    public static let notAuthorizedForGBP = Self(97)
    public static let notAuthorizedForTry = Self(100)
    public static let maxPaymentCards = Self(101)
    public static let maxPaymentBankAccounts = Self(143)
    public static let notAuthorizedForRub = Self(144)
    public static let maxAuthAttemptsReached = Self(145)
    public static let withdrawalForbidden = Self(130)
    public static let insufficientBalance = Self(131)
    public static let orderInProgress = Self(132)
    public static let simpleBuyExpirationError = Self(133)
    public static let simpleBuyForceExecutionError = Self(134)
    public static let invalidPaymentMethod = Self(135)
    public static let noRatesAvailable = Self(136)
    public static let eddQuestionairePending = Self(146)
    public static let withdrawalLocked = Self(152)
    public static let invalidDestinationAddress = Self(148)
    public static let invalidFiatCurrency = Self(149)
    public static let orderDirectionDisabled = Self(151)
    public static let addressGenerationFailure = Self(153)
    public static let notFoundCustodialQuote = Self(155)
    public static let userNotEligibleForSwap = Self(156)
    public static let orderAmountNegative = Self(157)
    public static let invalidKYCForSavings = Self(140)
    public static let currencyNotSupported = Self(141)
    public static let productNotSupported = Self(142)
    public static let missingRangeParameter = Self(147)
    public static let featureNotAvailable = Self(154)
    public static let documentDataRequired = Self(160)
    public static let notAvailableInLegalEntity = Self(172)
    public static let cardInsufficientFunds = Self(10000)
    public static let cardBankDecline = Self(10001)
    public static let cardDuplicate = Self(10002)
    public static let cardBlockchainDecline = Self(10003)
    public static let cardAcquirerDecline = Self(10004)
    public static let cardPaymentNotSupported = Self(10005)
    public static let cardCreateFailed = Self(10006)
    public static let cardPaymentFailed = Self(10007)
    public static let cardCreateAbandoned = Self(10008)
    public static let cardCreateExpired = Self(10009)
    public static let cardCreateBankDeclined = Self(10010)
    public static let cardCreateDebitOnly = Self(10011)
    public static let cardPaymentDebitOnly = Self(10012)
    public static let cardCreateNoToken = Self(10013)
    public static let cardIssuingKycFailed = Self(11000)
    public static let cardIssuingSsnInvalid = Self(11001)
    public static let countryNotEligible = Self(170)
    public static let stateNotEligible = Self(171)
    public static let provePossessionFailed = Self(300)
    public static let proveVerificationFailed = Self(301)
}

extension CodingUserInfoKey {
    public static let networkURLRequest = CodingUserInfoKey(rawValue: "com.blockchain.network.url.request")!
    public static let networkHTTPResponse = CodingUserInfoKey(rawValue: "com.blockchain.network.http.response")!
}
