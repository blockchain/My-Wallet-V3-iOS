// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import UIKit

public enum Screen {
    public enum Style {}
}

public protocol ScreenNavigationButton: Equatable {
    var content: Screen.NavigationBarContent? { get }
}

extension Screen {
    public struct NavigationBarContent: Equatable {
        let title: String?
        let image: UIImage?
        let accessibility: Accessibility?

        public init(
            title: String? = nil,
            image: UIImage? = nil,
            accessibility: Accessibility? = nil
        ) {
            self.title = title
            self.image = image
            self.accessibility = accessibility
        }
    }
}

extension Screen.Style {

    // MARK: - The bar style

    /// Describes the bar style
    public enum Bar: Equatable {

        /// Light content bar style
        /// Dark background and light content
        case lightContent(
            ignoresStatusBar: Bool = false,
            background: UIColor = UIColor.NavigationBar.LightContent.background
        )

        /// Dark content bar style
        /// Light background and dark content
        case darkContent(
            ignoresStatusBar: Bool = false,
            background: UIColor = UIColor.NavigationBar.DarkContent.background
        )

        case mutedContent(
            ignoresStatusBar: Bool = false,
            background: UIColor = UIColor.NavigationBar.LightContent.background
        )
    }

    // MARK: - Title view style

    /// The view that represents the title
    public enum TitleView: Equatable {

        /// Textual view
        case text(value: String)

        /// Custom view
        case view(value: UIView)

        /// Visual image based view. Only the width can be customized.
        case image(name: String, width: CGFloat)

        /// No title view
        case none
    }

    // MARK: - Trailing button style

    /// Describes the trailing button style
    public enum TrailingButton: ScreenNavigationButton {

        /// No trailing button style
        case none

        /// Displayable content
        case content(Screen.NavigationBarContent)

        /// Processing by displaying an activity indicator
        case processing

        /// QR code
        case qrCode

        /// Close icon
        case close

        /// Question Mark Icon
        case questionMark

        /// Skip icon
        case skip
    }

    // MARK: - The leading button style

    /// Describes the leading button style
    public enum LeadingButton: ScreenNavigationButton {

        /// No button
        case none

        /// Back button, pops the view controller
        case back

        /// Close button, dismisses the view controller
        case close

        /// Button with text
        case text(value: String)
    }
}

extension Screen.Style.Bar {

    /// The color to apply to the navigation bar title.
    public var titleColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.NavigationBar.LightContent.title
        case .darkContent:
            return UIColor.NavigationBar.DarkContent.title
        case .mutedContent:
            return UIColor.NavigationBar.MutedContent.title
        }
    }

    /// The tint color to apply to the navigation items and bar button items.(`UINavigationBar.tintColor`)
    public var tintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.NavigationBar.LightContent.tintColor
        case .darkContent:
            return UIColor.NavigationBar.DarkContent.tintColor
        case .mutedContent:
            return UIColor.NavigationBar.MutedContent.tintColor
        }
    }

    /// The tint color to apply to the leading navigation items and bar button items.(`UINavigationBar.tintColor`)
    public var leadingTintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.NavigationBar.LightContent.tintColor
        case .darkContent:
            return UIColor.NavigationBar.DarkContent.tintColor
        case .mutedContent:
            return UIColor.NavigationBar.MutedContent.tintColor
        }
    }

    /// The tint color to apply to the trailing navigation items and bar button items.(`UINavigationBar.tintColor`)
    public var trailingTintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.NavigationBar.LightContent.tintColor
        case .darkContent:
            return UIColor.NavigationBar.DarkContent.tintColor
        case .mutedContent:
            return UIColor.NavigationBar.MutedContent.trailingColor
        }
    }

    public var titleFont: UIFont {
        .main(.medium, 16)
    }

    public var titleTextAttributes: [NSAttributedString.Key: Any] {
        [
            .font: titleFont,
            .foregroundColor: titleColor
        ]
    }

    /// The tint color to apply to the navigation bar background. (`UINavigationBar.barTintColor`)
    public var backgroundColor: UIColor {
        switch self {
        case .darkContent(ignoresStatusBar: _, background: let color),
            .lightContent(ignoresStatusBar: _, background: let color),
            .mutedContent(ignoresStatusBar: _, background: let color):
            return color
        }
    }

    /// Indicates if, when setting the style on a view, the `UIAppliation.statusBarStyle` bar should be ignored (not updated).
    ///
    /// `false`: Status bar will be set to `lightContent'/'default' accordingly to this bar style.
    ///
    /// `true`: Status bar style will not be modified
    var ignoresStatusBar: Bool {
        switch self {
        case .darkContent(ignoresStatusBar: let value, background: _),
             .lightContent(ignoresStatusBar: let value, background: _),
             .mutedContent(ignoresStatusBar: let value, background: _):
            return value
        }
    }
}

extension Screen.Style.TrailingButton {

    /// Returns the content of the button
    public var content: Screen.NavigationBarContent? {
        switch self {
        case .content(let content):
            return content
        case .qrCode:
            return Screen.NavigationBarContent(
                image: UIImage(named: "qr-code-icon"),
                accessibility: .id(Accessibility.Identifier.NavigationBar.qrCodeButton)
            )
        case .close:
            return Screen.NavigationBarContent(
                image: UIImage(named: "Icon-Close-Circle"),
                accessibility: .id(Accessibility.Identifier.NavigationBar.dismissButton)
            )
        case .questionMark:
            return Screen.NavigationBarContent(
                image: UIImage(named: "Question Circle", in: .componentLibrary, with: nil),
                accessibility: .id(Accessibility.Identifier.NavigationBar.supportButton)
            )

        case .skip:
            return Screen.NavigationBarContent(
                title: "Skip",
                image: nil,
                accessibility: .id(Accessibility.Identifier.NavigationBar.skipButton)
            )

        default:
            return nil
        }
    }
}

/// Describes the leading button style
extension Screen.Style.LeadingButton {

    /// Returns the content of the button
    public var content: Screen.NavigationBarContent? {
        switch self {
        case .text(value: let text):
            return Screen.NavigationBarContent(title: text)
        case .close:
            return Screen.NavigationBarContent(
                image: UIImage(named: "navigation-close-icon"),
                accessibility: .id(Accessibility.Identifier.NavigationBar.dismissButton)
            )
        case .back:
            return Screen.NavigationBarContent(
                image: Icon.chevronLeft.uiImage,
                accessibility: .id(Accessibility.Identifier.NavigationBar.backButton)
            )
        case .none:
            return nil
        }
    }
}
