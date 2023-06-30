// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxSwift
import UIKit

public struct BadgeImageViewModel {

    // MARK: - Types

    public struct Theme {
        public let backgroundColor: UIColor
        public let cornerRadius: CornerRadius
        public let imageViewContent: ImageViewContent
        public let marginOffset: CGFloat
        public let sizingType: SizingType

        public init(
            backgroundColor: UIColor = .clear,
            cornerRadius: CornerRadius = .roundedLow,
            imageViewContent: ImageViewContent = .empty,
            marginOffset: CGFloat = 4,
            sizingType: SizingType = .configuredByOwner
        ) {
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.imageViewContent = imageViewContent
            self.marginOffset = marginOffset
            self.sizingType = sizingType
        }
    }

    public enum SizingType {
        case configuredByOwner
        case constant(CGSize)
    }

    public enum CornerRadius {
        /// Straight corners
        case none
        /// An 4pt corner radius
        case roundedLow
        /// An 8pt corner radius
        case roundedHigh
        /// A corner radius that makes the item round.
        case round
    }

    // MARK: - Properties

    /// Corner radius
    public let cornerRadiusRelay: BehaviorRelay<CornerRadius>

    /// Image to be displayed on the badge
    public var cornerRadius: Driver<CornerRadius> {
        cornerRadiusRelay.asDriver()
    }

    /// The background color relay
    public let backgroundColorRelay: BehaviorRelay<UIColor>

    /// The background color of the badge
    public var backgroundColor: Driver<UIColor> {
        backgroundColorRelay.asDriver()
    }

    public let marginOffsetRelay: BehaviorRelay<CGFloat>
    public var marginOffset: Driver<CGFloat> {
        marginOffsetRelay.asDriver()
    }

    public let sizingTypeRelay: BehaviorRelay<SizingType>
    public var sizingType: Driver<SizingType> {
        sizingTypeRelay.asDriver()
    }

    /// The image name relay
    public let imageContentRelay: BehaviorRelay<ImageViewContent>

    /// Image to be displayed on the badge
    public var imageContent: Driver<ImageViewContent> {
        imageContentRelay.asDriver()
    }

    /// - parameter cornerRadius: corner radius of the component
    public init(theme: Theme = Theme()) {
        self.backgroundColorRelay = .init(value: theme.backgroundColor)
        self.cornerRadiusRelay = .init(value: theme.cornerRadius)
        self.imageContentRelay = .init(value: theme.imageViewContent)
        self.marginOffsetRelay = .init(value: theme.marginOffset)
        self.sizingTypeRelay = .init(value: theme.sizingType)
    }

    func set(theme: Theme) {
        backgroundColorRelay.accept(theme.backgroundColor)
        cornerRadiusRelay.accept(theme.cornerRadius)
        imageContentRelay.accept(theme.imageViewContent)
        marginOffsetRelay.accept(theme.marginOffset)
        sizingTypeRelay.accept(theme.sizingType)
    }
}

// MARK: - Factory

extension BadgeImageViewModel {

    private typealias AccessibilityId = Accessibility.Identifier.BadgeImageView

    public static var empty: BadgeImageViewModel {
        BadgeImageViewModel()
    }

    /// Returns a default badge with an image.
    ///
    /// It uses the standard `background` color and does not apply a tintColor to the image.
    /// It has rounded corners.
    public static func `default`(
        image: ImageResource?,
        backgroundColor: UIColor = UIColor.semantic.light,
        cornerRadius: CornerRadius = .roundedHigh,
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let theme = Theme(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            imageViewContent: ImageViewContent(
                imageResource: image,
                accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                renderingMode: .normal
            )
        )
        return BadgeImageViewModel(theme: theme)
    }

    public static func template(
        image: ImageResource,
        templateColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CornerRadius,
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let theme = Theme(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            imageViewContent: ImageViewContent(
                imageResource: image,
                accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                renderingMode: .template(templateColor)
            )
        )
        return BadgeImageViewModel(theme: theme)
    }

    /// Returns a primary badge with an image.
    ///
    /// It uses the standard `defaultBadge` color for the content and applies a `lightBadgeBackground` to the background.
    /// It has rounded corners, though you can apply a `cornerRadius`
    public static func primary(
        image: ImageResource,
        contentColor: UIColor = .init(light: .defaultBadge, dark: .tertiary),
        backgroundColor: UIColor = .lightBadgeBackground,
        cornerRadius: CornerRadius = .roundedHigh,
        accessibilityIdSuffix: String
    ) -> BadgeImageViewModel {
        let theme = Theme(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            imageViewContent: ImageViewContent(
                imageResource: image,
                accessibility: .id("\(AccessibilityId.prefix)\(accessibilityIdSuffix)"),
                renderingMode: .template(contentColor)
            )
        )
        return BadgeImageViewModel(theme: theme)
    }
}

extension BadgeImageViewModel: Equatable {
    public static func == (lhs: BadgeImageViewModel, rhs: BadgeImageViewModel) -> Bool {
        lhs.imageContentRelay.value == rhs.imageContentRelay.value
    }
}
