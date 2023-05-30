// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCardPaymentDomain
import PlatformKit
import PlatformUIKit
import RxCocoa

final class LinkedCardViewModel {

    // MARK: - Private Types

    private typealias AccessibilityIDs = Accessibility.Identifier.LinkedCardView

    // MARK: - Types

    struct Theme {
        let cardName: String
        let cardNameFont: UIFont
        let cardNameContentColor: UIColor
        let limit: String
        let limitFont: UIFont
        let limitContentColor: UIColor

        init(
            cardName: String,
            cardNameFont: UIFont = .main(.semibold, 16.0),
            cardNameContentColor: UIColor = .semantic.title,
            limit: String,
            limitFont: UIFont = .main(.medium, 14.0),
            limitContentColor: UIColor = .semantic.text
        ) {
            self.cardName = cardName
            self.cardNameFont = cardNameFont
            self.cardNameContentColor = cardNameContentColor
            self.limit = limit
            self.limitFont = limitFont
            self.limitContentColor = limitContentColor
        }
    }

    struct Content {
        let nameContent: LabelContent
        let limitContent: LabelContent
        let limitText: String
        let nameText: String

        init(theme: Theme) {
            self.limitText = theme.limit
            self.nameText = theme.cardName
            self.nameContent = .init(
                text: theme.cardName,
                font: theme.cardNameFont,
                color: theme.cardNameContentColor,
                alignment: .left,
                accessibility: .id(AccessibilityIDs.name)
            )
            self.limitContent = .init(
                text: theme.limit,
                font: theme.limitFont,
                color: theme.limitContentColor,
                alignment: .left,
                accessibility: .id(AccessibilityIDs.limit)
            )
        }
    }

    // MARK: - Properties

    /// The theme of the view
    var content: Content {
        get {
            Content(theme: Theme(
                cardName: nameTextRelay.value,
                limit: limitTextRelay.value
            )
            )
        }
        set {
            nameTextRelay.accept(newValue.nameText)
            nameContentRelay.accept(newValue.nameContent)
            limitTextRelay.accept(newValue.limitText)
            limitContentRelay.accept(newValue.limitContent)
        }
    }

    var nameContent: Driver<LabelContent> {
        nameContentRelay.asDriver()
    }

    var limitContent: Driver<LabelContent> {
        limitContentRelay.asDriver()
    }

    let accessibility: Accessibility = .id(AccessibilityIDs.view)
    let badgeImageViewModel: BadgeImageViewModel

    // MARK: - Private

    private let nameContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let limitContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let nameTextRelay = BehaviorRelay(value: "")
    private let limitTextRelay = BehaviorRelay(value: "")

    init(type: CardType) {
        self.badgeImageViewModel = .default(
            image: type.thumbnail,
            cornerRadius: .roundedLow,
            accessibilityIdSuffix: type.name
        )
        badgeImageViewModel.marginOffsetRelay.accept(0)
    }
}

extension Accessibility.Identifier {
    enum LinkedCardView {
        private static let prefix = "LinkedCardView."
        static let view = "\(prefix)view"
        static let name = "\(prefix)name"
        static let limit = "\(prefix)limit"
    }
}
