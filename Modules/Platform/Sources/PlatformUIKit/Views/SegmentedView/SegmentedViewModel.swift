// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit
import UIKit

/// The view model coupled with `SegmentedViewModel`.
/// Rx driven: drives changes in the view: opacity, enable/disable, image and text can be assigned dynamically.
/// Supports accessibility.
/// - Tag: `SegmentedViewModel`
public struct SegmentedViewModel {

    // MARK: - Types

    public struct Theme {
        public let font: UIFont
        public let selectedFont: UIFont
        public let backgroundColor: UIColor?
        public let dividerColor: UIColor?
        public let contentColor: UIColor?
        public let selectedContentColor: UIColor?
        public let borderColor: UIColor

        public init(
            font: UIFont,
            selectedFont: UIFont,
            backgroundColor: UIColor? = nil,
            borderColor: UIColor = .clear,
            dividerColor: UIColor? = nil,
            contentColor: UIColor? = nil,
            selectedContentColor: UIColor? = nil
        ) {
            self.font = font
            self.selectedFont = selectedFont
            self.selectedContentColor = selectedContentColor
            self.dividerColor = dividerColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.contentColor = contentColor
        }
    }

    public struct Item {

        /// `Content` is the styling of the item. It can either have an image
        /// or a title, but not both.
        public enum Content {
            case title(String)
            case imageName(String)
        }

        /// The action that will be triggered when the `Item` is tapped.
        public let action: (() -> Void)?

        /// The identity of this segment item
        public let id: AnyHashable?

        /// The content displayed on the `Item`. It can be a stringValue
        /// or an image, but not both.
        public let content: Content

        // MARK: - Init

        init(content: Content, id: AnyHashable? = nil, action: (() -> Void)? = nil) {
            self.content = content
            self.id = id
            self.action = action
        }

        public static func image(named image: String, action: (() -> Void)? = nil) -> Item {
            .init(content: .imageName(image), action: action)
        }

        public static func text(_ text: String, action: (() -> Void)? = nil) -> Item {
            .init(content: .title(text), action: action)
        }
    }

    // MARK: - Properties

    /// The theme of the view
    public var theme: Theme {
        @available(*, unavailable)
        get {
            unimplemented()
        }
        set {
            selectedFontRelay.accept(newValue.selectedFont)
            normalFontRelay.accept(newValue.font)
            selectedFontColorRelay.accept(newValue.selectedContentColor)
            dividerColorRelay.accept(newValue.dividerColor)
            backgroundColorRelay.accept(newValue.backgroundColor)
            borderColorRelay.accept(newValue.borderColor)
            contentColorRelay.accept(newValue.contentColor)
        }
    }

    /// Accessibility for the button view
    public let accessibility: Accessibility

    public let isMomentary: Bool

    /// Corner radius
    public let cornerRadius: CGFloat

    /// Items for selection
    public let items: [Item]

    public let defaultSelectedSegmentIndex: Int

    /// Observe the button enabled state
    public let isEnabledRelay = BehaviorRelay<Bool>(value: true)

    /// Is the button enabled
    public var isEnabled: Driver<Bool> {
        isEnabledRelay.asDriver()
    }

    /// Retruns the opacity of the view
    public var alpha: Driver<CGFloat> {
        isEnabled.asDriver().map { CGFloat($0 ? 1 : 0.65) }
    }

    /// The background color relay
    public let backgroundColorRelay = BehaviorRelay<UIColor?>(value: nil)

    /// The background color of the button
    public var backgroundColor: Driver<UIColor?> {
        backgroundColorRelay.asDriver()
    }

    /// The content color relay
    public let contentColorRelay = BehaviorRelay<UIColor?>(value: nil)

    /// The content color of the button, that includes image's and label's
    public var contentColor: Driver<UIColor?> {
        contentColorRelay.asDriver()
    }

    public var selectedFontColor: Driver<UIColor?> {
        selectedFontColorRelay.asDriver()
    }

    /// The font when the segment is not selected
    public var normalFont: Driver<UIFont> {
        normalFontRelay.asDriver()
    }

    /// The font when the segment is selected
    public var selectedFont: Driver<UIFont> {
        selectedFontRelay.asDriver()
    }

    /// Border color relay
    public let borderColorRelay = BehaviorRelay<UIColor>(value: .clear)
    public let dividerColorRelay = BehaviorRelay<UIColor?>(value: nil)
    public let selectedFontColorRelay = BehaviorRelay<UIColor?>(value: nil)
    public let normalFontRelay = BehaviorRelay<UIFont>(value: .main(.medium, 14))
    public let selectedFontRelay = BehaviorRelay<UIFont>(value: .main(.medium, 14))

    /// The border color around the button
    public var borderColor: Driver<UIColor> {
        borderColorRelay.asDriver()
    }

    /// The color of the divider between segments.
    public var dividerColor: Driver<UIColor?> {
        dividerColorRelay.asDriver()
    }

    /// The text relay
    public let textRelay = BehaviorRelay<String>(value: "")

    /// Text to be displayed on the button
    public var text: Driver<String> {
        textRelay.asDriver()
    }

    private let disposeBag = DisposeBag()

    /// Streams events when the component is being tapped
    public let tapRelay = PublishRelay<Int>()

    /// - parameter cornerRadius: corner radius of the component
    /// - parameter accessibility: accessibility for the view
    public init(
        isMomentary: Bool,
        cornerRadius: CGFloat,
        defaultSelectedSegmentIndex: Int,
        accessibility: Accessibility,
        items: [Item]
    ) {
        self.defaultSelectedSegmentIndex = defaultSelectedSegmentIndex
        self.isMomentary = isMomentary
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
        self.items = items

        tapRelay
            .filter { $0 >= 0 }
            .map { items[$0] }
            .compactMap(\.action)
            .bind { action in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                action()
            }
            .disposed(by: disposeBag)
    }

    /// Set the theme using a mild fade animation
    public func animate(theme: Theme) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                backgroundColorRelay.accept(theme.backgroundColor)
                borderColorRelay.accept(theme.borderColor)
                contentColorRelay.accept(theme.contentColor)
            }
        )
    }
}

extension SegmentedViewModel {

    /// Returns a primary segmented control
    public static func primary(
        items: [Item],
        isMomentary: Bool = false,
        defaultSelectedSegmentIndex: Int = 0,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
    ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            isMomentary: isMomentary,
            cornerRadius: cornerRadius,
            defaultSelectedSegmentIndex: defaultSelectedSegmentIndex,
            accessibility: .id(accessibilityId),
            items: items
        )
        viewModel.theme = Theme(
            font: .main(.semibold, 16),
            selectedFont: .main(.semibold, 16),
            backgroundColor: .background,
            contentColor: .descriptionText,
            selectedContentColor: .primaryButton
        )
        return viewModel
    }

    public static func `default`(
        items: [Item],
        isMomentary: Bool = false,
        defaultSelectedSegmentIndex: Int = 0,
        cornerRadius: CGFloat = 8,
        accessibilityId: String = Accessibility.Identifier.General.primarySegmentedControl
    ) -> SegmentedViewModel {
        var viewModel = SegmentedViewModel(
            isMomentary: isMomentary,
            cornerRadius: cornerRadius,
            defaultSelectedSegmentIndex: defaultSelectedSegmentIndex,
            accessibility: .id(accessibilityId),
            items: items
        )
        viewModel.theme = Theme(
            font: .main(.medium, 14),
            selectedFont: .main(.semibold, 14),
            backgroundColor: .background,
            contentColor: .mutedText,
            selectedContentColor: .titleText
        )
        return viewModel
    }
}
