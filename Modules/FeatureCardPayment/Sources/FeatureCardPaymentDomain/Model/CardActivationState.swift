// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CardActivationState {
    case active(CardData)
    case pending
    case inactive(CardData?)

    public var isPending: Bool {
        switch self {
        case .pending:
            return true
        case .active, .inactive:
            return false
        }
    }

    public init(_ cardPayload: CardPayload) {
        guard let cardData = CardData(response: cardPayload) else {
            self = .inactive(nil)
            return
        }
        switch cardPayload.state {
        case .active:
            self = .active(cardData)
        case .pending:
            self = .pending
        case .blocked, .expired, .created, .none, .fraudReview, .manualReview:
            self = .inactive(cardData)
        }
    }
}

// MARK: - Response Setup

extension CardPayload.State {
    public var platform: CardPayload.State {
        switch self {
        case .active:
            return .active
        case .blocked:
            return .blocked
        case .created:
            return .created
        case .expired:
            return .expired
        case .fraudReview:
            return .fraudReview
        case .manualReview:
            return .manualReview
        case .none:
            return .none
        case .pending:
            return .pending
        }
    }
}

extension CardPayload.Partner {
    public var platform: CardPayload.Partner {
        switch self {
        case .cardProvider:
            return .cardProvider
        case .everypay:
            return .everypay
        case .cassy:
            return .cassy
        case .unknown:
            return .unknown
        }
    }
}
