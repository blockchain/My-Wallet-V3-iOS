// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public struct FieldConfiguation {
    public struct BottomButton {
        let leadingPrefixText: String?
        let title: String
        let action: () -> Void

        public init(
            leadingPrefixText: String?,
            title: String,
            action: @escaping () -> Void
        ) {
            self.leadingPrefixText = leadingPrefixText
            self.title = title
            self.action = action
        }
    }

    let textAutocorrectionType: UITextAutocorrectionType
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let onFieldTapped: (() -> Void)?
    let bottomButton: BottomButton?
    let inputPrefixConfig: InputPrefixConfig
    let onTextChange: ((String) -> String?)?

    /// TextField Input Component
    /// - Parameters:
    ///   - textAutocorrectionType: default Autocorrection
    ///   - onFieldTapped: if this handler passed, the field will be disabled
    ///   - bottomButton: bottom button
    public init(
        textAutocorrectionType: UITextAutocorrectionType = .default,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        onFieldTapped: (() -> Void)? = nil,
        bottomButton: BottomButton? = nil,
        inputPrefixConfig: InputPrefixConfig = .default(),
        onTextChange: ((String) -> String?)? = nil
    ) {
        self.textAutocorrectionType = textAutocorrectionType
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.onFieldTapped = onFieldTapped
        self.bottomButton = bottomButton
        self.inputPrefixConfig = inputPrefixConfig
        self.onTextChange = onTextChange
    }
}
