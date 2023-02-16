// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A SearchBar Input from the Figma Component Library.
///
/// # Usage:
///
///     SearchBar(
///         text: $text,
///         isFirstResponder: $isFirstResponder,
///         placeholder: "Password", // Appears when `text` is empty
///         cancelButtonText: "Cancel", // Appears when focused or `text` is not empty
///         onReturnTapped: {
///             search()
///         }
///     )
///
/// # Figma
///
/// [Search](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=369%3A8929)
public struct SearchBar: View {
    @Binding private var text: String
    @Binding private var isFirstResponder: Bool

    private let placeholder: String?
    private let cancelButtonText: String
    private let subText: String?
    private let subTextStyle: InputSubTextStyle
    private let hasAutocorrection: Bool
    private let onReturnTapped: () -> Void

    /// Create a search bar
    /// - Parameters:
    ///   - text: The text to display and edit
    ///   - isFirstResponder: Whether the textfield is focused
    ///   - cancelButtonText: Text displayed in the trailing cancel button when focused or containing content
    ///   - subText: Optional text displayed below the search bar
    ///   - subTextStyle: Styling of the text displayed below the search bar, See `InputSubTextStyle`
    ///   - placeholder: Optional placeholder text displayed when `text` is empty.
    ///   - onReturnTapped: Closure executed when the user types the return key
    public init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        hasAutocorrection: Bool = true,
        cancelButtonText: String,
        subText: String? = nil,
        subTextStyle: InputSubTextStyle = .default,
        placeholder: String? = nil,
        onReturnTapped: @escaping () -> Void = {}
    ) {
        _text = text
        _isFirstResponder = isFirstResponder
        self.hasAutocorrection = hasAutocorrection
        self.cancelButtonText = cancelButtonText
        self.subText = subText
        self.subTextStyle = subTextStyle
        self.placeholder = placeholder
        self.onReturnTapped = onReturnTapped
    }

    public var body: some View {
        HStack(spacing: 15) {
            Input(
                text: $text,
                isFirstResponder: $isFirstResponder,
                subText: subText,
                subTextStyle: subTextStyle,
                placeholder: placeholder,
                borderRadius: Spacing.containerBorderRadius,
                defaultBorderColor: .clear,
                configuration: { textField in
                    #if canImport(UIKit)
                    textField.returnKeyType = .search
                    textField.autocorrectionType = hasAutocorrection ? .yes : .no
                    #endif
                },
                trailing: {
                    if !text.isEmpty {
                        IconButton(icon: .closev2.circle()) {
                            text = ""
                        }
                        .transition(isFirstResponder ? .opacity : .move(edge: .leading))
                    } else if !isFirstResponder {
                        IconButton(icon: .search.color(.semantic.title)) {
                            isFirstResponder = true
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                },
                onReturnTapped: {
                    isFirstResponder = false
                    onReturnTapped()
                }
            )

            if !cancelButtonText.isEmpty, !text.isEmpty || isFirstResponder {
                Button(
                    action: {
                        text = ""
                        isFirstResponder = false
                    },
                    label: {
                        Text(cancelButtonText)
                            .typography(.body1)
                            .foregroundColor(.semantic.primary)
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.interactiveSpring())
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer(
            text: "",
            isFirstResponder: false
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Unfocused empty")

        PreviewContainer(
            text: "Uniswa",
            isFirstResponder: false
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Unfocused with Content")

        PreviewContainer(
            text: "",
            isFirstResponder: true
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Focused Empty")

        PreviewContainer(
            text: "Uniswa",
            isFirstResponder: true
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Focused with Content")
    }

    struct PreviewContainer: View {
        @State var text: String
        @State var isFirstResponder: Bool

        var body: some View {
            SearchBar(
                text: $text,
                isFirstResponder: $isFirstResponder,
                cancelButtonText: "Cancel",
                placeholder: "Search Coin"
            )
        }
    }
}
