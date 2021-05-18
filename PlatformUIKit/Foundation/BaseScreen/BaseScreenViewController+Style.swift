//
//  Screen.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

public enum Screen {
    public enum Style { }
}

public protocol ScreenNavigationButton {
    var content: Screen.NavigationBarContent? { get }
}

extension Screen {
    public struct NavigationBarContent {
        let title: String?
        let image: UIImage?
        let accessibility: Accessibility?
        public init(title: String? = nil,
                    image: UIImage? = nil,
                    accessibility: Accessibility? = nil) {
            self.title = title
            self.image = image
            self.accessibility = accessibility
        }
    }
}

extension Screen.Style {

    // MARK: - The bar style

    /// Describes the bar style
    public enum Bar {

        /// Light content bar style
        /// Dark background and light content
        case lightContent(
            ignoresStatusBar: Bool = false,
            isTranslucent: Bool = false,
            background: UIColor = UIColor.NavigationBar.LightContent.background
        )

        /// Dark content bar style
        /// Light background and dark content
        case darkContent(
            ignoresStatusBar: Bool = false,
            isTranslucent: Bool = false,
            background: UIColor = UIColor.NavigationBar.DarkContent.background
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

        /// A button for opening a drawer
        case drawer

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
        }
    }

    /// The tint color to apply to the navigation items and bar button items.(`UINavigationBar.tintColor`)
    public var tintColor: UIColor {
        switch self {
        case .lightContent:
            return UIColor.NavigationBar.LightContent.tintColor
        case .darkContent:
            return UIColor.NavigationBar.DarkContent.tintColor
        }
    }

    public var titleFont: UIFont {
        .main(.medium, 20)
    }

    public var titleTextAttributes: [ NSAttributedString.Key: Any ] {
        [
            .font: titleFont,
            .foregroundColor: titleColor
        ]
    }

    /// The tint color to apply to the navigation bar background. (`UINavigationBar.barTintColor`)
    public var backgroundColor: UIColor {
        switch self {
        case .darkContent(ignoresStatusBar: _, isTranslucent: _, background: let color),
             .lightContent(ignoresStatusBar: _, isTranslucent: _, background: let color):
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
        case .darkContent(ignoresStatusBar: let value, isTranslucent: _, background: _),
             .lightContent(ignoresStatusBar: let value, isTranslucent: _, background: _):
            return value
        }
    }

    /// Is translucent.
    public var isTranslucent: Bool {
        switch self {
        case .darkContent(ignoresStatusBar: _, isTranslucent: let value, background: _),
             .lightContent(ignoresStatusBar: _, isTranslucent: let value, background: _):
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
                accessibility: .init(
                    id: .value(Accessibility.Identifier.NavigationBar.qrCodeButton)
                )
            )
        case .close:
            return Screen.NavigationBarContent(
                image: UIImage(named: "Icon-Close-Circle"),
                accessibility: .init(
                    id: .value(Accessibility.Identifier.NavigationBar.dismissButton)
                )
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
        case .drawer:
            return Screen.NavigationBarContent(
                image: UIImage(named: "drawer-icon"),
                accessibility: .init(
                    id: .value(Accessibility.Identifier.NavigationBar.drawerButton)
                )
            )
        case .close:
            return Screen.NavigationBarContent(
                image: UIImage(named: "navigation-close-icon"),
                accessibility: .init(
                    id: .value(Accessibility.Identifier.NavigationBar.dismissButton)
                )
            )
        case .back:
            return Screen.NavigationBarContent(
                image: UIImage(named: "back_icon"),
                accessibility: .init(
                    id: .value(Accessibility.Identifier.NavigationBar.backButton)
                )
            )
        case .none:
            return nil
        }
    }
}
