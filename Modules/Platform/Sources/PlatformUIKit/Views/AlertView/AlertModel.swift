// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public struct AlertModel {
    public var image: UIImage?
    public var imageTintColor: UIColor?
    public var topNote: String?
    public var headline: String?
    public var body: String?
    public var note: String?
    public var actions: [AlertAction]
    public var dismissable: Bool
    public var style: AlertViewStyle

    public init(
        headline: String?,
        body: String?,
        note: String? = nil,
        topNote: String? = nil,
        actions: [AlertAction] = [.defaultDismissal],
        image: UIImage? = nil,
        imageTintColor: UIColor? = nil,
        dismissable: Bool = true,
        style: AlertViewStyle = .default
    ) {
        self.headline = headline
        self.body = body
        self.note = note
        self.topNote = topNote
        self.actions = actions
        self.image = image
        self.imageTintColor = imageTintColor
        self.dismissable = dismissable
        self.style = style
    }
}

public struct AlertAction {
    public let style: AlertActionStyle
    public let metadata: ActionMetadata?

    public init(style: AlertActionStyle, metadata: ActionMetadata? = nil) {
        self.style = style
        self.metadata = metadata
    }
}

extension AlertAction {

    public static let defaultDismissal = AlertAction(style: .dismiss)

    public var title: String? {
        switch style {
        case .confirm(let title):
            title
        case .default(let title):
            title
        case .dismiss:
            nil
        }
    }
}

public enum AlertActionStyle: Equatable {
    public typealias Title = String
    /// Filled in `UIButton` with white text.
    /// It appears _above_ the `default` style button.
    case confirm(Title)
    /// `UIButton` with blue border and blue text.
    /// It appears _below_ the `confirm` style button.
    case `default`(Title)
    /// When the user taps outside of the view to dismiss it.
    case dismiss
}

extension AlertActionStyle {
    public static func == (lhs: AlertActionStyle, rhs: AlertActionStyle) -> Bool {
        switch (lhs, rhs) {
        case (.confirm(let left), .confirm(let right)):
            left == right
        case (.default(let left), .default(let right)):
            left == right
        case (.dismiss, .dismiss):
            true
        default:
            false
        }
    }
}

public enum AlertViewStyle {
    case `default`
    case sheet
}
