// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

/// A view model for selection-view to use throughout the app
public final class SelectionButtonViewModel: IdentifiableType {

    // MARK: - Types

    public struct AccessibilityContent {
        public let id: String
        public let label: String

        fileprivate static var empty: AccessibilityContent {
            AccessibilityContent(id: "", label: "")
        }

        fileprivate var accessibility: Accessibility {
            Accessibility(
                id: id,
                label: label,
                traits: .button,
                isAccessible: !id.isEmpty
            )
        }

        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }

    public enum LeadingContent {
        case badgeImage(BadgeImageViewModel)
        case label(LabelContent)
        case none
    }

    public enum TrailingContent {
        case transaction(TransactionDescriptorViewModel)
        case image(ImageViewContent)
        case empty

        var transaction: TransactionDescriptorViewModel? {
            switch self {
            case .transaction(let value):
                return value
            case .image, .empty:
                return nil
            }
        }

        var image: ImageViewContent? {
            switch self {
            case .image(let value):
                return value
            case .transaction, .empty:
                return nil
            }
        }
    }

    public enum LeadingContentType {
        public struct Image {
            let image: ImageResource
            let background: Color
            let cornerRadius: BadgeImageViewModel.CornerRadius
            let offset: CGFloat
            let size: CGSize
            let renderingMode: ImageViewContent.RenderingMode

            public init(
                image: ImageResource,
                background: Color,
                offset: CGFloat = 4,
                cornerRadius: BadgeImageViewModel.CornerRadius,
                size: CGSize,
                renderingMode: ImageViewContent.RenderingMode = .normal
            ) {
                self.image = image
                self.background = background
                self.offset = offset
                self.cornerRadius = cornerRadius
                self.size = size
                self.renderingMode = renderingMode
            }
        }

        case image(Image)
        case text(String)
    }

    private typealias AccessibilityId = Accessibility.Identifier.SelectionButtonView

    // MARK: - Public Properties

    public var identity: AnyHashable {
        titleRelay.value + (subtitleRelay.value ?? "")
    }

    /// Title Relay: title describing the selection
    public let titleRelay = BehaviorRelay<String>(value: "")

    /// Title Font Relay: Font of the leading title
    public let titleFontRelay = BehaviorRelay<UIFont>(value: .main(.semibold, 16))

    /// Title Color Relay: Color of the title
    public let titleFontColor = BehaviorRelay<UIColor>(value: .titleText)

    /// Subtitle Relay:  The subtitle describing the selection
    ///
    /// A  nil value represents the inexistence of a subtitle, in which case a view may react to this by changing its layout.
    public let subtitleRelay = BehaviorRelay<String?>(value: "")

    /// Subtitle Font Relay: Font of the leading subtitle
    public let subtitleFontRelay = BehaviorRelay<UIFont>(value: .main(.medium, 14))

    /// Subtitle Color Relay: Color of the subtitle
    public let subtitleFontColor = BehaviorRelay<UIColor>(value: .descriptionText)

    /// Image Name Relay:  A `String` for image asset name.
    public let leadingContentTypeRelay = BehaviorRelay<LeadingContentType?>(value: nil)

    /// The leading content's size
    public var leadingImageViewSize: Driver<CGSize> {
        leadingContentTypeRelay
            .asDriver()
            .map { type in
                switch type {
                case .image(let image):
                    return image.size
                case .text, .none:
                    return CGSize(edge: 1)
                }
            }
    }

    /// Accessibility for the title
    public let titleAccessibilityRelay = BehaviorRelay<Accessibility>(
        value: .id(Accessibility.Identifier.ContentLabelView.title)
    )

    /// Accessibility for the subtitle
    public let subtitleAccessibilityRelay = BehaviorRelay<Accessibility>(
        value: .id(Accessibility.Identifier.ContentLabelView.description)
    )

    /// Accessibility content relay
    public let accessibilityContentRelay = BehaviorRelay<AccessibilityContent>(value: .empty)

    /// Trailing content relay
    public let trailingContentRelay = BehaviorRelay<TrailingContent>(value: .empty)

    /// Title Relay: title describing the selection
    public let shouldShowSeparatorRelay = BehaviorRelay(value: false)

    /// Horizontal offset relay
    public let horizontalOffsetRelay = BehaviorRelay<CGFloat>(value: 24)

    /// Vertical offset relay
    public let verticalOffsetRelay = BehaviorRelay<CGFloat>(value: 16)

    /// Allows any component to observe taps
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    /// Determines if the button accepts touches
    public let isButtonEnabledRelay = BehaviorRelay(value: true)
    var isButtonEnabled: Driver<Bool> {
        isButtonEnabledRelay.asDriver()
    }

    // MARK: - Internal Properties

    /// A tap relay that accepts taps on the button
    let tapRelay = PublishRelay<Void>()

    /// The horizontal offset of the content
    var horizontalOffset: Driver<CGFloat> {
        horizontalOffsetRelay.asDriver()
    }

    /// The vertical offset of the content
    var verticalOffset: Driver<CGFloat> {
        verticalOffsetRelay.asDriver()
    }

    /// Streams the leading image
    var shouldShowSeparator: Driver<Bool> {
        shouldShowSeparatorRelay.asDriver()
    }

    /// Streams the leading content
    var leadingContent: Driver<LeadingContent> {
        leadingContentRelay.asDriver()
    }

    /// Streams the title
    var title: Driver<LabelContent> {
        Observable
            .combineLatest(
                titleRelay.asObservable(),
                titleAccessibilityRelay.asObservable(),
                titleFontRelay.asObservable(),
                titleFontColor.asObservable()
            )
            .map { title, accessibility, font, color in
                LabelContent(
                    text: title,
                    font: font,
                    color: color,
                    accessibility: accessibility
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    /// Streams the title
    var subtitle: Driver<LabelContent?> {
        Observable
            .combineLatest(
                subtitleRelay.asObservable(),
                subtitleAccessibilityRelay.asObservable(),
                subtitleFontRelay.asObservable(),
                subtitleFontColor.asObservable()
            )
            .map { subtitle, accessibility, font, color in
                guard let subtitle else {
                    return nil
                }
                return LabelContent(
                    text: subtitle,
                    font: font,
                    color: color,
                    adjustsFontSizeToFitWidth: .true(factor: 0.7),
                    accessibility: accessibility
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    /// Streams the trailing content
    var trailingContent: Driver<TrailingContent> {
        trailingContentRelay
            .asDriver()
    }

    /// Streams the accessibility
    var accessibility: Driver<Accessibility> {
        accessibilityContentRelay
            .asDriver()
            .map(\.accessibility)
    }

    // MARK: - Private Properties

    private let leadingContentRelay = BehaviorRelay<LeadingContent>(value: .none)
    private let disposeBag = DisposeBag()

    public init(showSeparator: Bool = false) {
        shouldShowSeparatorRelay.accept(showSeparator)

        leadingContentTypeRelay
            .map { type in
                switch type {
                case .image(let image):
                    let imageViewContent = ImageViewContent(
                        imageResource: image.image,
                        renderingMode: image.renderingMode
                    )
                    let badgeViewModel = BadgeImageViewModel()
                    badgeViewModel.set(
                        theme: .init(
                            backgroundColor: image.background,
                            cornerRadius: image.cornerRadius,
                            imageViewContent: imageViewContent,
                            marginOffset: image.offset
                        )
                    )
                    return .badgeImage(badgeViewModel)
                case .text(let text):
                    return .label(
                        LabelContent(
                            text: text,
                            font: .main(.medium, 30),
                            color: .semantic.title
                        )
                    )
                case .none:
                    return .none
                }
            }
            .bindAndCatch(to: leadingContentRelay)
            .disposed(by: disposeBag)
    }
}
