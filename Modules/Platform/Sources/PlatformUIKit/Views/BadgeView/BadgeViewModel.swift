// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxSwift
import UIKit

public struct BadgeViewModel {

    // MARK: - Types

    public struct Theme {
        public let backgroundColor: UIColor
        public let contentColor: UIColor
        public let text: String

        public init(
            backgroundColor: UIColor,
            contentColor: UIColor,
            text: String
        ) {
            self.backgroundColor = backgroundColor
            self.contentColor = contentColor
            self.text = text
        }
    }

    public enum Accessory {
        case progress(BadgeCircleViewModel)
    }

    // MARK: - Properties

    /// The theme of the view
    public var theme: Theme {
        get {
            Theme(
                backgroundColor: backgroundColorRelay.value,
                contentColor: contentColorRelay.value,
                text: textRelay.value
            )
        }
        set {
            backgroundColorRelay.accept(newValue.backgroundColor)
            contentColorRelay.accept(newValue.contentColor)
            textRelay.accept(newValue.text)
        }
    }

    /// Accessibility for the badge view
    public let accessibility: Accessibility

    /// Corner radius
    public let cornerRadius: CGFloat

    /// The font of the label
    public let font: UIFont

    public let accessory: Accessory?

    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)

    /// The background color of the badge
    public var backgroundColor: Driver<UIColor> {
        backgroundColorRelay.asDriver()
    }

    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)

    /// The content color of the title
    public var contentColor: Driver<UIColor> {
        contentColorRelay.asDriver()
    }

    /// The text relay
    public let textRelay = BehaviorRelay<String>(value: "")

    /// Text to be displayed on the badge
    public var text: Driver<String> {
        textRelay.asDriver()
    }

    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(font: UIFont = .main(.semibold, 14), cornerRadius: CGFloat = 4, accessory: Accessory? = nil, accessibility: Accessibility) {
        self.font = font
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
        self.accessory = accessory
    }
}

extension BadgeViewModel {

    /// Returns a destructive badge with text
    public static func destructive(
        with text: String,
        accessibilityId: String = Accessibility.Identifier.General.destructiveBadgeView
    ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessibility: .id(accessibilityId)
        )
        viewModel.theme = Theme(
            backgroundColor: UIColor(light: .destructiveBackground, dark: .errorBorder),
            contentColor: UIColor(light: .destructiveButton, dark: .darkTitleText),
            text: text
        )
        return viewModel
    }

    /// Returns a affirmative badge with text
    public static func affirmative(
        with text: String,
        accessibilityId: String = Accessibility.Identifier.General.affirmativeBadgeView
    ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessibility: .id(accessibilityId)
        )
        viewModel.theme = Theme(
            backgroundColor: UIColor(light: .affirmativeBackground, dark: .affirmativeBadgeDark),
            contentColor: UIColor(light: .affirmativeBadgeText, dark: .darkTitleText),
            text: text
        )
        return viewModel
    }

    /// Returns a affirmative badge with text
    public static func progress(
        with text: String,
        model: BadgeCircleViewModel,
        accessibilityId: String = Accessibility.Identifier.General.affirmativeBadgeView
    ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            accessory: .progress(model),
            accessibility: .id(accessibilityId)
        )
        viewModel.theme = Theme(
            backgroundColor: .white,
            contentColor: .defaultBadge,
            text: text
        )
        return viewModel
    }

    /// Returns a default badgeViewModel with text only
    public static func warning(
        with text: String,
        font: UIFont = .main(.semibold, 14),
        cornerRadius: CGFloat = 4,
        accessibilityId: String = Accessibility.Identifier.General.warningBadgeView
    ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            font: font,
            cornerRadius: cornerRadius,
            accessibility: .id(accessibilityId)
        )
        viewModel.theme = Theme(
            backgroundColor: UIColor(light: .badgeBackgroundWarning, dark: .tertiary),
            contentColor: UIColor(light: .warningBadge, dark: .darkTitleText),
            text: text
        )
        return viewModel
    }

    /// Returns a default badgeViewModel with text only
    public static func `default`(
        with text: String,
        font: UIFont = .main(.semibold, 14),
        cornerRadius: CGFloat = 4,
        accessibilityId: String = Accessibility.Identifier.General.defaultBadgeView
    ) -> BadgeViewModel {
        var viewModel = BadgeViewModel(
            font: font,
            cornerRadius: cornerRadius,
            accessibility: .id(accessibilityId)
        )
        viewModel.theme = Theme(
            backgroundColor: UIColor(light: .defaultBadgeBackground, dark: .idleBorder), // idleBorder is blue400 :(
            contentColor: UIColor(light: .defaultBadge, dark: .darkTitleText),
            text: text
        )
        return viewModel
    }
}

// MARK: - Equatable

extension BadgeViewModel: Equatable {
    public static func == (lhs: BadgeViewModel, rhs: BadgeViewModel) -> Bool {
        lhs.textRelay.value == rhs.textRelay.value
    }
}
