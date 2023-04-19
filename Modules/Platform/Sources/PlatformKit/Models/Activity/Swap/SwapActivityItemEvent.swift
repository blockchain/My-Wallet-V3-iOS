// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

public struct SwapActivityItemEvent: Decodable {

    public let identifier: String
    public let status: EventStatus
    public let date: Date
    public let pair: Pair
    public let kind: SwapKind
    private let priceFunnel: PriceFunnel
    public let amounts: Amounts

    public var withdrawalTxHash: String? {
        kind.withdrawalTxHash
    }

    public var depositTxHash: String? {
        kind.depositTxHash
    }

    public var isCustodial: Bool {
        !isNonCustodial
    }

    public var isNonCustodial: Bool {
        kind.direction == .onChain
    }

    public struct Pair {
        public let inputCurrencyType: CurrencyType
        public let outputCurrencyType: CurrencyType

        init(
            inputCurrencyType: CurrencyType,
            outputCurrencyType: CurrencyType
        ) {
            self.inputCurrencyType = inputCurrencyType
            self.outputCurrencyType = outputCurrencyType
        }

        init(string: String, values: KeyedDecodingContainer<CodingKeys>) throws {

            var components: [String] = []
            for value in ["-", "_"] where string.contains(value) {
                components = string.components(separatedBy: value)
                break
            }

            let error = DecodingError.dataCorruptedError(
                forKey: .pair,
                in: values,
                debugDescription: "Expected a valid pair"
            )

            guard let input = components.first else { throw error }
            guard let output = components.last else { throw error }
            do {
                try self.init(
                    inputCurrencyType: CurrencyType(code: input),
                    outputCurrencyType: CurrencyType(code: output)
                )
            } catch {
                throw error
            }
        }
    }

    public struct Amounts {
        public let deposit: MoneyValue
        public let withdrawal: MoneyValue
        public let withdrawalFee: MoneyValue
        public let fiatValue: FiatValue

        init(
            deposit: MoneyValue,
            withdrawal: MoneyValue,
            withdrawalFee: MoneyValue,
            fiatValue: FiatValue
        ) {
            self.deposit = deposit
            self.withdrawal = withdrawal
            self.withdrawalFee = withdrawalFee
            self.fiatValue = fiatValue
        }
    }

    public enum EventStatus {
        case inProgress(ProgressStatus)
        case pendingRefund
        case refunded
        case failed
        case expired
        case delayed
        case complete
        case none

        public var isFinal: Bool {
            switch self {
            case .refunded, .failed, .expired, .complete:
                return true
            default:
                return false
            }
        }

        public enum ProgressStatus: String {
            case pendingExecution = "PENDING_EXECUTION"
            case pendingDeposit = "PENDING_DEPOSIT"
            case finishedDeposit = "FINISHED_DEPOSIT"
            case pendingWithdrawal = "PENDING_WITHDRAWAL"
        }

        public var localizedDescription: String {
            switch self {
            case .complete:
                return LocalizationConstants.Swap.completed
            case .delayed,
                 .inProgress,
                 .none,
                 .pendingRefund:
                return LocalizationConstants.Swap.pending
            case .expired,
                 .failed,
                 .refunded:
                return LocalizationConstants.Swap.failed
            }
        }

        public init(value: String) {
            switch value {
            case "NONE":
                self = .none
            case "PENDING_EXECUTION":
                self = .inProgress(.pendingExecution)
            case "PENDING_DEPOSIT":
                self = .inProgress(.pendingDeposit)
            case "FINISHED_DEPOSIT":
                self = .inProgress(.finishedDeposit)
            case "PENDING_WITHDRAWAL":
                self = .inProgress(.pendingWithdrawal)
            case "PENDING_REFUND":
                self = .pendingRefund
            case "REFUNDED":
                self = .refunded
            case "FINISHED":
                self = .complete
            case "FAILED":
                self = .failed
            case "EXPIRED":
                self = .expired
            case "DELAYED":
                self = .delayed
            default:
                self = .none
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status = "state"
        case createdAt
        case pair
        case deposit
        case fiatValue
        case fiatCurrency
        case priceFunnel
        case kind
    }

    private struct PriceFunnel: Decodable {
        let inputMoney: String
        let price: String
        let networkFee: String
        let staticFee: String
        let outputMoney: String
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let createdAt = try values.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter.sessionDateFormat
        let legacyFormatter = DateFormatter.iso8601Format

        // Some trades don't have a consistant date format. Some
        // use the same format as what we use for establishing a
        // secure session, some use ISO8601.
        if let value = formatter.date(from: createdAt) {
            self.date = value
        } else if let value = legacyFormatter.date(from: createdAt) {
            self.date = value
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }

        self.identifier = try values.decode(String.self, forKey: .identifier)
        let pairValue = try values.decode(String.self, forKey: .pair)

        let statusValue = try values.decode(String.self, forKey: .status)
        self.status = EventStatus(value: statusValue)
        self.pair = try Pair(string: pairValue, values: values)
        self.kind = try values.decode(SwapKind.self, forKey: .kind)
        self.priceFunnel = try values.decode(PriceFunnel.self, forKey: .priceFunnel)

        let fiatAmount = try values.decode(String.self, forKey: .fiatValue)
        let fiatCurrency = try values.decode(FiatCurrency.self, forKey: .fiatCurrency)
        guard let fiatValue = FiatValue.create(minor: fiatAmount, currency: fiatCurrency) else {
            throw DecodingError.dataCorruptedError(
                forKey: .fiatCurrency,
                in: values,
                debugDescription: "Expected a valid fiat currency."
            )
        }
        guard let deposit = MoneyValue.create(minor: priceFunnel.outputMoney, currency: pair.outputCurrencyType) else {
            throw DecodingError.dataCorruptedError(
                forKey: .deposit,
                in: values,
                debugDescription: "Expected a valid output money amount"
            )
        }
        guard let withdrawal = MoneyValue.create(minor: priceFunnel.inputMoney, currency: pair.inputCurrencyType) else {
            throw DecodingError.dataCorruptedError(
                forKey: .priceFunnel,
                in: values,
                debugDescription: "Expected a valid input money amount"
            )
        }

        guard let fee = MoneyValue.create(minor: priceFunnel.networkFee, currency: pair.inputCurrencyType) else {
            throw DecodingError.dataCorruptedError(
                forKey: .priceFunnel,
                in: values,
                debugDescription: "Expected a valid network fee"
            )
        }

        self.amounts = Amounts(
            deposit: deposit,
            withdrawal: withdrawal,
            withdrawalFee: fee,
            fiatValue: fiatValue
        )
    }
}

extension SwapActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension SwapActivityItemEvent: Equatable {
    public static func == (lhs: SwapActivityItemEvent, rhs: SwapActivityItemEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status &&
            lhs.date == rhs.date &&
            lhs.pair == rhs.pair &&
            lhs.kind == rhs.kind &&
            lhs.amounts == rhs.amounts &&
            lhs.withdrawalTxHash == rhs.withdrawalTxHash &&
            lhs.depositTxHash == rhs.depositTxHash
    }
}

extension SwapActivityItemEvent.EventStatus: Equatable {
    public static func == (
        lhs: SwapActivityItemEvent.EventStatus,
        rhs: SwapActivityItemEvent.EventStatus
    ) -> Bool {
        switch (lhs, rhs) {
        case (.inProgress(let left), .inProgress(let right)):
            return left == right
        case (.pendingRefund, .pendingRefund),
             (.refunded, .refunded),
             (.failed, .failed),
             (.expired, .expired),
             (.delayed, .delayed),
             (.complete, .complete),
             (.none, .none):
            return true
        default:
            return false
        }
    }
}

extension SwapActivityItemEvent.Pair: Equatable {
    public static func == (lhs: SwapActivityItemEvent.Pair, rhs: SwapActivityItemEvent.Pair) -> Bool {
        lhs.outputCurrencyType == rhs.outputCurrencyType &&
            lhs.inputCurrencyType == rhs.inputCurrencyType
    }
}

extension SwapActivityItemEvent.Amounts: Equatable {
    public static func == (lhs: SwapActivityItemEvent.Amounts, rhs: SwapActivityItemEvent.Amounts) -> Bool {
        lhs.deposit == rhs.deposit &&
            lhs.fiatValue == rhs.fiatValue &&
            lhs.withdrawal == rhs.withdrawal &&
            lhs.withdrawalFee == rhs.withdrawalFee
    }
}

extension SwapActivityItemEvent {
    public var ccy: String {
        pair.outputCurrencyType.code
    }
}
