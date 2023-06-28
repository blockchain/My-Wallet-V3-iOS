// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// An announcement card view model
public final class AnnouncementCardViewModel {

    // MARK: - Types

    public typealias AccessibilityId = Accessibility.Identifier.AnnouncementCard
    public typealias DidAppear = () -> Void

    /// The priority under which the announcement should show
    public enum Priority {
        case high
        case low
    }

    /// The style of the background
    public struct Background {

        /// A blank white background. a computed property.
        public static var white: Background {
            Background(color: .white)
        }

        /// The background color
        let color: UIColor

        /// The background image
        let imageName: String?

        let bundle: Bundle

        /// Computes the `UIImage` out of `imageName`
        var image: UIImage? {
            guard let imageName else { return nil }
            return UIImage(
                named: imageName,
                in: bundle,
                compatibleWith: .none
            )
        }

        public init(color: UIColor = .clear, imageName: String? = nil, bundle: Bundle = .main) {
            self.imageName = imageName
            self.color = color
            self.bundle = bundle
        }
    }

    /// The border style of the card
    public enum Border {

        /// Round corners with radius value
        case roundCorners(_ radius: CGFloat)

        /// Separator
        case bottomSeparator(_ color: UIColor)

        /// No border
        case none
    }

    /// The alignment of the content
    public enum Alignment {

        /// Natual alignment (leading -> trailing)
        case natural

        /// Center alignment
        case center
    }

    public enum BadgeImage {
        case hidden
        case visible(BadgeImageViewModel, CGSize)

        public init(
            image: ImageResource,
            contentColor: UIColor? = .defaultBadge,
            backgroundColor: UIColor = .lightBadgeBackground,
            cornerRadius: BadgeImageViewModel.CornerRadius = .roundedHigh,
            accessibilityID: String = AccessibilityId.badge,
            size: CGSize
        ) {
            let image = ImageViewContent(
                imageResource: image,
                accessibility: .id(accessibilityID),
                renderingMode: contentColor.flatMap { .template($0) } ?? .normal
            )
            let theme = BadgeImageViewModel.Theme(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                imageViewContent: image,
                marginOffset: 0
            )
            self = .visible(.init(theme: theme), size)
        }

        var verticalPadding: CGFloat {
            switch self {
            case .hidden:
                return 0.0
            case .visible:
                return 16.0
            }
        }

        var size: CGSize {
            switch self {
            case .hidden:
                return .zero
            case .visible(_, let value):
                return value
            }
        }

        var viewModel: BadgeImageViewModel? {
            switch self {
            case .hidden:
                return nil
            case .visible(let value, _):
                return value
            }
        }

        var isVisible: Bool {
            switch self {
            case .hidden:
                return false
            case .visible:
                return true
            }
        }
    }

    /// The dismissal state of the card announcement
    public enum DismissState {

        public typealias Action = () -> Void

        /// Indicates the announcement is dismissable and the associated `Action`
        /// is should be executed upon dismissal
        case dismissible(Action)

        /// Indicates the announcement is not dismissable. Therefore `X` button is hidden.
        case undismissible
    }

    /// The interaction of the user with the card itself
    public enum Interaction {

        /// The background is tappable
        case tappable(() -> Void)

        /// No interaction
        case none

        var isTappable: Bool {
            switch self {
            case .tappable:
                return true
            case .none:
                return false
            }
        }
    }

    // MARK: - Properties

    let interaction: Interaction
    let badgeImage: BadgeImage
    let contentAlignment: Alignment
    let background: Background
    let border: Border
    let title: String?
    let description: String?
    let buttons: [ButtonViewModel]
    let didAppear: DidAppear?

    /// Returns `true` if the dismiss button should be hidden
    var isDismissButtonHidden: Bool {
        switch dismissState {
        case .undismissible:
            return true
        case .dismissible:
            return false
        }
    }

    /// The action associated with the announcement dismissal.
    var dismissAction: DismissState.Action? {
        switch dismissState {
        case .dismissible(let action):
            return action
        case .undismissible:
            return nil
        }
    }

    private let dismissState: DismissState

    /// Upon receiving events triggers dismissal.
    /// This comes in handy when the user has performed an indirect
    /// action that should cause card dismissal.
    let dismissalRelay = PublishRelay<Void>()

    private var dismissal: Completable {
        dismissalRelay
            .take(1)
            .ignoreElements()
            .asCompletable()
            .observe(on: MainScheduler.instance)
    }

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interaction: Interaction = .none,
        badgeImage: BadgeImage = .hidden,
        contentAlignment: Alignment = .natural,
        background: Background = .white,
        border: Border = .bottomSeparator(.mediumBorder),
        title: String? = nil,
        description: String? = nil,
        buttons: [ButtonViewModel] = [],
        dismissState: DismissState,
        didAppear: DidAppear? = nil
    ) {
        self.interaction = interaction
        self.badgeImage = badgeImage
        self.contentAlignment = contentAlignment
        self.background = background
        self.border = border
        self.title = title
        self.description = description
        self.dismissState = dismissState
        self.buttons = buttons
        self.didAppear = didAppear

        if let dismissAction {
            dismissal
                .subscribe(onCompleted: dismissAction)
                .disposed(by: disposeBag)
        }
    }
}
