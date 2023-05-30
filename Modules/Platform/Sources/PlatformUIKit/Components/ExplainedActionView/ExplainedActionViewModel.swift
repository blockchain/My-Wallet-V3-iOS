// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import PlatformKit
import RxCocoa
import RxSwift

public struct DescriptionTitle {
    public var title: String
    public var titleColor: UIColor
    public var titleFontSize: CGFloat

    public init(title: String, titleColor: UIColor, titleFontSize: CGFloat) {
        self.title = title
        self.titleColor = titleColor
        self.titleFontSize = titleFontSize
    }
}

public struct ExplainedActionViewModel {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.ExplainedActionView

    // MARK: - Setup

    let thumbBadgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContents: [LabelContent]
    let badgeViewModel: BadgeViewModel?
    var isEnabled: Bool

    // MARK: - Accessors

    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    let tapRelay = PublishRelay<Void>()

    // MARK: - Setup

    public init(
        thumbImage: String,
        title: String,
        descriptions: [DescriptionTitle],
        badgeTitle: String?,
        uniqueAccessibilityIdentifier: String,
        thumbRenderDefault: Bool = false,
        isEnabled: Bool = true
    ) {
        if thumbRenderDefault {
            self.thumbBadgeImageViewModel = .default(
                image: .local(name: thumbImage, bundle: .platformUIKit),
                backgroundColor: .clear,
                cornerRadius: .none,
                accessibilityIdSuffix: uniqueAccessibilityIdentifier
            )
        } else {
            self.thumbBadgeImageViewModel = .primary(
                image: .local(name: thumbImage, bundle: .platformUIKit),
                cornerRadius: .round,
                accessibilityIdSuffix: uniqueAccessibilityIdentifier
            )
            thumbBadgeImageViewModel.marginOffsetRelay.accept(6)
        }

        self.titleLabelContent = .init(
            text: title,
            font: .main(.semibold, 16),
            color: UIColor.semantic.title,
            accessibility: .id(uniqueAccessibilityIdentifier + AccessibilityId.titleLabel)
        )
        self.descriptionLabelContents = descriptions
            .enumerated()
            .map { payload in
                .init(
                    text: payload.element.title,
                    font: .main(.medium, 14),
                    color: payload.element.titleColor,
                    accessibility: .id(
                        uniqueAccessibilityIdentifier + AccessibilityId.descriptionLabel + ".\(payload.offset)"
                    )
                )
            }

        if let badgeTitle {
            self.badgeViewModel = .affirmative(
                with: badgeTitle,
                accessibilityId: uniqueAccessibilityIdentifier + AccessibilityId.badgeView
            )
        } else { // hide badge
            self.badgeViewModel = nil
        }

        self.isEnabled = isEnabled
    }

    func capabilities(capabilities: [PaymentMethod.Capability]?, eligible: Bool) -> Self {
        var it = self
        if let capabilities {
            it.isEnabled = eligible && (capabilities.contains(.withdrawal) || capabilities.contains(.deposit))
        } else {
            it.isEnabled = eligible
        }
        return it
    }
}

extension ExplainedActionViewModel: Equatable {
    public static func == (lhs: ExplainedActionViewModel, rhs: ExplainedActionViewModel) -> Bool {
        lhs.badgeViewModel == rhs.badgeViewModel
            && lhs.titleLabelContent == rhs.titleLabelContent
            && lhs.thumbBadgeImageViewModel == rhs.thumbBadgeImageViewModel
            && lhs.descriptionLabelContents == rhs.descriptionLabelContents
            && lhs.isEnabled == rhs.isEnabled
    }
}
