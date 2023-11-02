// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import ToolKit

public enum TransactionalLineItem: Hashable {
    typealias AccessibilityID = Accessibility.Identifier.LineItem.Transactional
    typealias LocalizedString = LocalizationConstants.LineItem.Transactional

    case amount(_ content: String? = nil)
    case `for`(_ content: String? = nil)
    case value(_ content: String? = nil)
    case fee(_ content: String? = nil)
    case buyingFee(_ content: String? = nil)
    case networkFee(_ content: String? = nil)
    case date(_ content: String? = nil)
    case estimatedAmount(_ content: String? = nil)
    case exchangeRate(_ content: String? = nil)
    case orderId(_ content: String? = nil)
    case paymentAccountField(PaymentAccountProperty.Field)
    case paymentMethod(_ content: String? = nil)
    case status(_ content: String? = nil)
    case sendingTo(_ content: String? = nil)
    case totalCost(_ content: String? = nil)
    case total(_ content: String? = nil)
    case from(_ content: String? = nil)
    case to(_ content: String? = nil)
    case gasFor(_ content: String? = nil)
    case memo(_ content: String? = nil)
    case availableToTrade(_ content: String? = nil)
    case cryptoPrice(_ content: String? = nil)
    case recurringBuyFrequency(_ content: String? = nil)

    public var accessibilityID: String {
        switch self {
        case .amount:
            AccessibilityID.amount
        case .for:
            AccessibilityID.for
        case .value:
            AccessibilityID.value
        case .fee:
            AccessibilityID.fee
        case .buyingFee:
            AccessibilityID.buyingFee
        case .networkFee:
            AccessibilityID.networkFee
        case .date:
            AccessibilityID.date
        case .estimatedAmount:
            AccessibilityID.estimatedAmount
        case .exchangeRate:
            AccessibilityID.exchangeRate
        case .orderId:
            AccessibilityID.orderId
        case .paymentAccountField(let field):
            field.accessibilityID
        case .paymentMethod:
            AccessibilityID.paymentMethod
        case .recurringBuyFrequency:
            AccessibilityID.recurringBuyFrequency
        case .sendingTo:
            AccessibilityID.sendingTo
        case .status:
            AccessibilityID.status
        case .totalCost:
            AccessibilityID.totalCost
        case .total:
            AccessibilityID.total
        case .from:
            AccessibilityID.from
        case .to:
            AccessibilityID.to
        case .gasFor:
            AccessibilityID.gasFor
        case .memo:
            AccessibilityID.memo
        case .availableToTrade:
            AccessibilityID.memo
        case .cryptoPrice:
            AccessibilityID.cryptoPrice
        }
    }

    public var content: String? {
        switch self {
        case .amount(let content),
             .buyingFee(let content),
             .networkFee(let content),
             .date(let content),
             .estimatedAmount(let content),
             .exchangeRate(let content),
             .orderId(let content),
             .paymentMethod(let content),
             .sendingTo(let content),
             .status(let content),
             .to(let content),
             .from(let content),
             .gasFor(let content),
             .memo(let content),
             .value(let content),
             .fee(let content),
             .for(let content),
             .totalCost(let content),
             .total(let content),
             .availableToTrade(let content),
             .cryptoPrice(let content),
             .recurringBuyFrequency(let content):
            content
        case .paymentAccountField(let field):
            field.content
        }
    }

    public var title: String {
        switch self {
        case .amount:
            LocalizedString.amount
        case .value:
            LocalizedString.value
        case .fee:
            LocalizedString.fee
        case .for:
            LocalizedString.for
        case .recurringBuyFrequency:
            LocalizedString.frequency
        case .buyingFee:
            LocalizedString.buyingFee
        case .networkFee:
            LocalizedString.processingFee
        case .date:
            LocalizedString.date
        case .estimatedAmount:
            LocalizedString.estimatedAmount
        case .exchangeRate:
            LocalizedString.exchangeRate
        case .orderId:
            LocalizedString.orderId
        case .paymentAccountField(let field):
            field.title
        case .paymentMethod:
            LocalizedString.paymentMethod
        case .sendingTo:
            LocalizedString.sendingTo
        case .status:
            LocalizedString.status
        case .total:
            LocalizedString.total
        case .totalCost:
            LocalizedString.totalCost
        case .to:
            LocalizedString.to
        case .from:
            LocalizedString.from
        case .gasFor:
            LocalizedString.gasFor
        case .memo:
            LocalizedString.memo
        case .availableToTrade:
            LocalizedString.availableToTrade
        case .cryptoPrice(let content):
            String(format: LocalizedString.cryptoPrice, content ?? "")
        }
    }

    public func defaultPresenter(accessibilityIdPrefix: String) -> DefaultLineItemCellPresenter {
        let interactor = DefaultLineItemCellInteractor(
            title: DefaultLabelContentInteractor(knownValue: title),
            description: DefaultLabelContentInteractor(knownValue: content ?? "")
        )
        return DefaultLineItemCellPresenter(
            interactor: interactor,
            accessibilityIdPrefix: "\(accessibilityIdPrefix)\(accessibilityID)"
        )
    }

    public var descriptionInteractionText: String {
        typealias LocalizedCopyable = LocalizedString.Copyable
        switch self {
        case .paymentAccountField(.iban):
            return "\(LocalizedCopyable.iban) \(LocalizedCopyable.copyMessageSuffix)"
        case .paymentAccountField(.bankCode):
            return "\(LocalizedCopyable.bankCode) \(LocalizedCopyable.copyMessageSuffix)"
        default:
            return LocalizedCopyable.defaultCopyMessage
        }
    }

    public func defaultCopyablePresenter(
        analyticsEvent: AnalyticsEvent? = nil,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        accessibilityIdPrefix: String
    ) -> PasteboardingLineItemCellPresenter {

        PasteboardingLineItemCellPresenter(
            input: .init(
                title: title,
                titleInteractionText: LocalizedString.Copyable.copied,
                description: content ?? "",
                descriptionInteractionText: descriptionInteractionText,
                analyticsEvent: analyticsEvent
            ),
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: "\(accessibilityIdPrefix)\(accessibilityID)"
        )
    }
}

extension PaymentAccountProperty.Field {
    public var accessibilityID: String {
        typealias AccessibilityID = Accessibility.Identifier.LineItem.Transactional
        switch self {
        case .accountNumber:
            return AccessibilityID.accountNumber
        case .sortCode:
            return AccessibilityID.sortCode
        case .recipientName:
            return AccessibilityID.recipient
        case .routingNumber:
            return AccessibilityID.routingNumber
        case .bankName:
            return AccessibilityID.bankName
        case .bankCountry:
            return AccessibilityID.bankCountry
        case .iban:
            return AccessibilityID.iban
        case .bankCode:
            return AccessibilityID.bankCode
        case .field(name: let name, value: _, help: _, copy: _):
            return name.snakeCase()
        }
    }
}
