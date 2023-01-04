// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Textfield Input from the Figma Component Library.
///
/// # Usage:
///
/// The actual final layout of this input depends on the parameters assigned on initialization.
/// label, subText, prefix, and trailing are optional parameters.
///
///     Input(
///         text: $text,
///         isFirstResponder: $isFirstResponder,
///         subText: "Your password is not long enough",
///         subTextStyle: .error,
///         placeholder: "Password",
///         state: .error,
///         configuration: { textField in
///             textField.isSecureTextEntry = true
///         }
///     ) {
///         Icon.eye
///     }
///
///
/// # Figma
///
///  [Input](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=377%3A8112)
public struct Input<Trailing: View>: View {
    #if canImport(UIKit)
    public typealias Configuration = (UITextField) -> Void
    #else
    public typealias Configuration = (()) -> Void
    #endif

    @Binding private var text: String
    @Binding private var isFirstResponder: Bool

    private let label: String?
    private let subText: String?
    private let subTextStyle: InputSubTextStyle
    private let placeholder: String?
    private let characterLimit: Int?
    private let prefix: String?
    private let prefixConfig: InputPrefixConfig
    private let state: InputState
    private let configuration: Configuration
    private let trailing: Trailing
    private let onReturnTapped: () -> Void
    private let onFieldTapped: (() -> Void)?
    private let isEnabledAutomaticFirstResponder: Bool
    private let shouldResignFirstResponderOnReturn: Bool
    private var isTextFieldDisabled: Bool {
        onFieldTapped != nil ? true : !isEnabled
    }
    /// when isEnabledAutomaticFirstResponder if false the tap on corner of field does not work. We add this property
    /// to know when we should start edit the field
    @State private var isFieldTapped: Bool = false
    @Environment(\.isEnabled) private var isEnabled

    /// TextField Input Component
    /// - Parameters:
    ///   - text: The text to display and edit
    ///   - isFirstResponder: Whether the textfield is focused
    ///   - isEnabledAutomaticFirstResponder: disable focus of the filed, to fix issue with
    ///   suggested email  autofill and password autogeneration. default is enabled
    ///   - label: Optional text displayed above the textfield
    ///   - subText: Optional text displayed below the textfield
    ///   - subTextStyle: Styling of the text displayed below the textfield, See `InputSubTextStyle`
    ///   - placeholder: Placeholder text displayed when `text` is empty.
    ///   - prefix: Optional text displayed on the leading side of the text field
    ///   - state: Error state overrides the border color.
    ///   - configuration: Closure to configure specifics of `UITextField`
    ///   - trailing: Optional trailing view, intended to contain `Icon` or `IconButton`.
    ///   - onReturnTapped: Closure executed when the user types the return key
    ///   - onFieldTapped: if this handler passed, the field will be disabled
    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        isEnabledAutomaticFirstResponder: Bool = true,
        shouldResignFirstResponderOnReturn: Bool = false,
        label: String? = nil,
        subText: String? = nil,
        subTextStyle: InputSubTextStyle = .default,
        placeholder: String? = nil,
        characterLimit: Int? = nil,
        prefix: String? = nil,
        prefixConfig: InputPrefixConfig = .default(),
        state: InputState = .default,
        configuration: @escaping Configuration = { _ in },
        @ViewBuilder trailing: @escaping () -> Trailing,
        onReturnTapped: @escaping () -> Void = {},
        onFieldTapped: (() -> Void)? = nil
    ) {
        _text = text
        _isFirstResponder = isFirstResponder
        self.isEnabledAutomaticFirstResponder = isEnabledAutomaticFirstResponder
        self.shouldResignFirstResponderOnReturn = shouldResignFirstResponderOnReturn
        self.label = label
        self.subText = subText
        self.subTextStyle = subTextStyle
        self.placeholder = placeholder
        self.characterLimit = characterLimit
        self.prefix = prefix
        self.prefixConfig = prefixConfig
        self.state = state
        self.configuration = configuration
        self.trailing = trailing()
        self.onReturnTapped = onReturnTapped
        self.onFieldTapped = onFieldTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            label.map(Text.init)?
                .typography(.paragraph2)
                .foregroundColor(Color(light: .semantic.title, dark: .palette.grey100))
                .padding(.bottom, 8)
                .padding(.top, 9)

            HStack(alignment: .center, spacing: prefixConfig.spacing) {
                prefix.map(Text.init)?
                    .typography(prefixConfig.typography)
                    .foregroundColor(prefixConfig.textColor)

                #if canImport(UIKit)
                FocusableTextField(
                    text: $text,
                    isFirstResponder: $isFirstResponder,
                    isEnabledAutomaticFirstResponder: isEnabledAutomaticFirstResponder,
                    shouldResignFirstResponderOnReturn: shouldResignFirstResponderOnReturn,
                    characterLimit: characterLimit,
                    configuration: { textField in
                        textField.font = Typography.bodyMono.uiFont
                        textField.textColor = UIColor(textColor)
                        textField.tintColor = UIColor(.semantic.primary)
                        textField.attributedPlaceholder = placeholder.map {
                            NSAttributedString(
                                string: $0,
                                attributes: [
                                    .font: Typography.bodyMono.uiFont as Any,
                                    .foregroundColor: UIColor(placeholderColor)
                                ]
                            )
                        }
                        if isFieldTapped {
                            textField.becomeFirstResponder()
                            Task { // small delay to wait until text field did become first responder
                                try await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
                                isFieldTapped = false
                            }
                        }
                        configuration(textField)
                    },
                    onReturnTapped: onReturnTapped
                )
                .frame(minHeight: 24)
                .disabled(isTextFieldDisabled)
                #else
                TextField("", text: $text)
                    .frame(minHeight: 24)
                    .disabled(isTextFieldDisabled)
                #endif

                trailing
                    .frame(width: 24, height: 24)
                    .accentColor(Color(light: .palette.grey400, dark: .palette.grey400))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                        .fill(backgroundColor)

                    RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                        .stroke(borderColor, lineWidth: 1)
                }
            )

            subText.map(Text.init)?
                .typography(.caption1)
                .foregroundColor(subTextStyle.foregroundColor)
                .padding(.top, 5)
                .padding(.bottom, 6)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let onFieldTapped {
                onFieldTapped()
            } else {
                isFirstResponder = true
                if !isEnabledAutomaticFirstResponder {
                    isFieldTapped = true
                }
            }
        }
    }
}

extension Input where Trailing == EmptyView {
    /// Create a Textfield Input component without a trailing view
    /// - Parameters:
    ///   - text: The text to display and edit
    ///   - isFirstResponder: Whether the textfield is focused
    ///   - label: Optional text displayed above the textfield
    ///   - subText: Optional text displayed below the textfield
    ///   - subTextStyle: Styling of the text displayed below the textfield, See `InputSubTextStyle`
    ///   - placeholder: Placeholder text displayed when `text` is empty.
    ///   - prefix: Optional text displayed on the leading side of the text field
    ///   - state: Error state overrides the border color.
    ///   - configuration: Closure to configure specifics of `UITextField`
    ///   - onReturnTapped: Closure executed when the user types the return key
    ///   - onFieldTapped: if this handler passed, the field will be disabled
    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        isEnabledAutomaticFirstResponder: Bool = true,
        shouldResignFirstResponderOnReturn: Bool = false,
        label: String? = nil,
        subText: String? = nil,
        subTextStyle: InputSubTextStyle = .default,
        placeholder: String? = nil,
        characterLimit: Int? = nil,
        prefix: String? = nil,
        prefixConfig: InputPrefixConfig = .default(),
        state: InputState = .default,
        configuration: @escaping Configuration = { _ in },
        onReturnTapped: @escaping () -> Void = {},
        onFieldTapped: (() -> Void)? = nil
    ) {
        self.init(
            text: text,
            isFirstResponder: isFirstResponder,
            isEnabledAutomaticFirstResponder: isEnabledAutomaticFirstResponder,
            shouldResignFirstResponderOnReturn: shouldResignFirstResponderOnReturn,
            label: label,
            subText: subText,
            subTextStyle: subTextStyle,
            placeholder: placeholder,
            characterLimit: characterLimit,
            prefix: prefix,
            prefixConfig: prefixConfig,
            state: state,
            configuration: configuration,
            trailing: { EmptyView() },
            onReturnTapped: onReturnTapped,
            onFieldTapped: onFieldTapped
        )
    }
}

/// Override for the border color of `Input`
public struct InputState: Equatable {
    let borderColor: Color?

    /// Default border colors, changing based on focus
    public static let `default` = Self(borderColor: nil)

    /// A red border color in all focus states
    public static let error = Self(borderColor: .semantic.error)

    /// A green border color in all focus states
    public static let success = Self(borderColor: .semantic.success)
}

/// Text style of the subtext below the text field in `Input`
public struct InputSubTextStyle {
    let foregroundColor: Color

    /// Default subtext style, grey text.
    public static let `default` = Self(foregroundColor: Color(light: .palette.grey600, dark: .palette.grey300))

    /// Primary styles the text using Color.semantic.primary
    public static let primary = Self(foregroundColor: .semantic.primary)

    /// Success subtext style, green text
    public static let success = Self(foregroundColor: .semantic.success)

    /// Error subtext style, red text
    public static let error = Self(foregroundColor: .semantic.error)
}

extension Input {
    // MARK: Colors

    private var backgroundColor: Color {
        if !isEnabled {
            return Color(light: .semantic.medium, dark: .palette.dark800)
        } else {
            return .semantic.background
        }
    }

    private var borderColor: Color {
        if let color = state.borderColor {
            return color
        } else if !isEnabled {
            return .semantic.medium
        } else if isFirstResponder {
            return .semantic.primary
        } else {
            return .semantic.medium
        }
    }

    private var textColor: Color {
        if !isEnabled {
            return placeholderColor
        } else {
            return .semantic.title
        }
    }

    private var placeholderColor: Color {
        Color(light: .semantic.muted, dark: .palette.grey600)
    }
}

public struct InputPrefixConfig {

    public static let defaultColor = Color(light: .semantic.muted, dark: .palette.grey600)
    let typography: Typography
    let textColor: Color
    let spacing: CGFloat

    public init(
        typography: Typography = .paragraph2,
        textColor: Color = defaultColor,
        spacing: CGFloat = Spacing.padding2
    ) {
        self.typography = typography
        self.textColor = textColor
        self.spacing = spacing
    }

    public static func `default`() -> InputPrefixConfig  {
        self.init()
    }
}

struct Input_Previews: PreviewProvider {
    static var previews: some View {
        Input(
            text: .constant(""),
            isFirstResponder: .constant(false),
            label: "Label Title",
            subText: "Error text to help explain a bit more",
            placeholder: "Placeholder"
        ) {
            Icon.placeholder
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Field")

        PreviewContainer(
            text: .constant(""),
            isFirstResponder: .constant(false),
            state: .default
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Placeholder")

        PreviewContainer(
            text: .constant(""),
            isFirstResponder: .constant(true),
            state: .default
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Placeholder Focused")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(false),
            state: .default
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Value Added")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(true),
            state: .default
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Value Added Focused")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(false),
            state: .error
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Error")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(true),
            state: .error
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Error Focused")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(false),
            state: .success
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Success")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(true),
            state: .success
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Success Focused")

        PreviewContainer(
            text: .constant("Blockchain"),
            isFirstResponder: .constant(false),
            state: .default
        )
        .disabled(true)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Disabled")
    }

    struct PreviewContainer: View {
        @Binding var text: String
        @Binding var isFirstResponder: Bool

        let state: InputState

        var body: some View {
            VStack {
                Input(
                    text: $text,
                    isFirstResponder: $isFirstResponder,
                    placeholder: "Placeholder",
                    prefix: nil,
                    state: state
                ) {
                    Icon.placeholder
                }

                Input(
                    text: .constant(text.isEmpty ? "" : "100"),
                    isFirstResponder: $isFirstResponder,
                    placeholder: "0",
                    prefix: "USD",
                    state: state
                )
            }
        }
    }
}
