// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CardActivationState {
    case active(CardData)
    case pending
    case inactive(CardData?)

    public var isPending: Bool {
        switch self {
        case .pending:
            true
        case .active, .inactive:
            false
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
            .active
        case .blocked:
            .blocked
        case .created:
            .created
        case .expired:
            .expired
        case .fraudReview:
            .fraudReview
        case .manualReview:
            .manualReview
        case .none:
            .none
        case .pending:
            .pending
        }
    }
}

extension CardPayload.Partner {
    public var platform: CardPayload.Partner {
        switch self {
        case .cardProvider:
            .cardProvider
        case .everypay:
            .everypay
        case .cassy:
            .cassy
        case .unknown:
            .unknown
        }
    }
}
