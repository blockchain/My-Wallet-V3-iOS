// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

public struct TextStyle: ViewModifier {

    public enum FontStyle {
        case title
        case heading
        case subheading
        case body
        case formFieldPlaceholder
    }

    public let fontStyle: FontStyle

    public func body(content: Content) -> some View {
        let textColor: Color
        let fontWeight: Typography.Weight
        let fontSize: CGFloat
        let lineSpacing: CGFloat
        let singleLineSpacing: CGFloat

        switch fontStyle {
        case .title:
            textColor = .semantic.title
            fontWeight = .semibold
            fontSize = LayoutConstants.Text.FontSize.title
            lineSpacing = LayoutConstants.Text.LineSpacing.title
            singleLineSpacing = lineSpacing
        case .heading:
            textColor = .semantic.title
            fontWeight = .semibold
            fontSize = LayoutConstants.Text.FontSize.heading
            lineSpacing = LayoutConstants.Text.LineSpacing.heading
            singleLineSpacing = lineSpacing
        case .subheading:
            textColor = .semantic.text
            fontWeight = .medium
            fontSize = LayoutConstants.Text.FontSize.subheading
            lineSpacing = LayoutConstants.Text.LineSpacing.subheading
            singleLineSpacing = 0
        case .body:
            textColor = .semantic.body
            fontWeight = .medium
            fontSize = LayoutConstants.Text.FontSize.body
            lineSpacing = LayoutConstants.Text.LineSpacing.body
            singleLineSpacing = 0
        case .formFieldPlaceholder:
            textColor = .textMuted
            fontWeight = .regular
            fontSize = LayoutConstants.Text.FontSize.formField
            lineSpacing = LayoutConstants.Text.LineSpacing.formField
            singleLineSpacing = lineSpacing
        }
        return content
            .font(Font(UIFont.main(fontWeight, fontSize)))
            .foregroundColor(textColor)
            .lineSpacing(lineSpacing) // to mimic line height in the designs
            .padding(.bottom, singleLineSpacing / 2) // to mimic line height on single line
    }
}

extension TextStyle {
    public static let title = TextStyle(fontStyle: .title)
    public static let heading = TextStyle(fontStyle: .heading)
    public static let subheading = TextStyle(fontStyle: .subheading)
    public static let body = TextStyle(fontStyle: .body)
    public static let formFieldPlaceholder = TextStyle(fontStyle: .formFieldPlaceholder)
}

extension View {

    public func textStyle(_ style: TextStyle) -> some View {
        modifier(style)
    }
}

#if DEBUG
struct TextStyle_Previews: PreviewProvider {

    static let shortSentence = "Almost before we knew it, we had left the ground."
    static let mediumSentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec condimentum id lacus vitae lacinia. Morbi accumsan lorem eu mauris rhoncus facilisis. Integer ut consectetur massa."
    static let longSentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec condimentum id lacus vitae lacinia. Morbi accumsan lorem eu mauris rhoncus facilisis. Integer ut consectetur massa. Mauris vulputate nisi vel elementum rutrum. Donec lobortis lectus sed posuere euismod. Nulla vitae justo nisl. Nam nec urna arcu. Aliquam imperdiet sed enim sed tincidunt. In vitae est quis massa venenatis sagittis nec ac metus."

    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(shortSentence)
                .textStyle(.title)
            VStack(alignment: .leading) {
                Text(shortSentence)
                    .textStyle(.heading)
                Text(mediumSentence)
                    .textStyle(.subheading)
            }
            Text(longSentence)
                .textStyle(.body)
        }
        .padding()
    }
}
#endif
