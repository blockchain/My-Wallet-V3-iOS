// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum ButtonSize {
    public enum Standard {
        public static let height: CGFloat = 56
        public static let cornerRadius: CGFloat = Spacing.roundedBorderRadius(
            for: height
        )
    }
}

/// A `struct` that contains sizing and spacing information about a button.
///
/// # Usage
/// Use the static properties provided for initialization. E.g.
///
/// ```
/// PillButtonSize.small
/// ```
///
/// This is meant to be used in conjunction with the `pillButtonSize` view modifier, like so:
///
/// ```
/// // Apply to a single button
/// PrimaryButton(...)
///  .pillButtonSize(.small)
///
/// // Apply to a group of buttons
/// VStack {
///     PrimaryButton(...)
/// }
/// .pillButtonSize(.small)
/// ```
public struct PillButtonSize {
    let typograhy: Typography
    let maxWidth: CGFloat?
    let minHeight: CGFloat
    let borderRadius: CGFloat
    let padding: EdgeInsets
}

extension PillButtonSize {

    /// Use to size a small button
    public static let small = PillButtonSize(
        typograhy: .paragraph2,
        maxWidth: nil,
        minHeight: 32,
        borderRadius: Spacing.roundedBorderRadius(for: 32),
        padding: EdgeInsets(
            top: 0,
            leading: Spacing.padding2,
            bottom: 0,
            trailing: Spacing.padding2
        )
    )

    /// Use to size a standard button
    public static let standard = PillButtonSize(
        typograhy: .body2,
        maxWidth: .infinity,
        minHeight: ButtonSize.Standard.height,
        borderRadius: ButtonSize.Standard.cornerRadius,
        padding: EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
    )

    public static let large = PillButtonSize(
        typograhy: .body2,
        maxWidth: .infinity,
        minHeight: 80,
        borderRadius: Spacing.buttonBorderRadius,
        padding: EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
    )
}
