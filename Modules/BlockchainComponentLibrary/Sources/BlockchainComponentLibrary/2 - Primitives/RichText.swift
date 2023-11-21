// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Markdown
import SwiftUI

/// Create Text from a subset of Markdown.
///
/// Also available via `Text(rich:)`, this is just around for convenience and visiblity.
///
/// # Allows for:
/// - `# Headers`
/// - `**Bold**`
/// - `*Italics* or _Italics_`
/// - `~~Strikethrough~~`
/// - `[https://blockchain.com](Links)` // Currently font color only, no tap action
///
/// - Parameter content: Markdown text to be parsed
public func RichText(_ text: some StringProtocol) -> SwiftUI.Text {
    SwiftUI.Text(rich: text)
}

extension SwiftUI.Text {

    /// Create Text from a subset of Markdown.
    ///
    /// Also available via `RichText(...)`
    ///
    /// # Allows for:
    /// - `# Headers`
    /// - `**Bold**`
    /// - `*Italics* or _Italics_`
    /// - `~~Strikethrough~~`
    /// - `[https://blockchain.com](Links)` // Currently font color only, no tap action
    ///
    /// - Parameter content: Markdown text to be parsed
    public init(rich content: some StringProtocol) {
        var visitor = Visitor()
        self = visitor.text(from: .init(parsing: String(content)))
    }
}

extension SwiftUI.Text {

    fileprivate struct Visitor: MarkupVisitor {

        mutating func text(from document: Document) -> SwiftUI.Text {
            visit(document)
        }

        mutating func text(from markup: Markup) -> SwiftUI.Text {
            visit(markup)
        }

        mutating func defaultVisit(_ markup: Markup) -> SwiftUI.Text {
            markup.children.reduce(.init("")) { text, markup in
                text + visit(markup)
            }
        }

        mutating func visitText(_ text: Markdown.Text) -> SwiftUI.Text {
            .init(text.plainText)
        }

        mutating func visitEmphasis(_ emphasis: Emphasis) -> SwiftUI.Text {
            defaultVisit(emphasis)
                .italic()
        }

        mutating func visitStrong(_ strong: Strong) -> SwiftUI.Text {
            defaultVisit(strong)
                .bold()
        }

        mutating func visitHeading(_ heading: Heading) -> SwiftUI.Text {
            let text = defaultVisit(heading).font(heading.typography.font)
            if heading.hasSuccessor {
                return text + .init("\n\n")
            } else {
                return text
            }
        }

        mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> SwiftUI.Text {
            defaultVisit(strikethrough)
                .strikethrough()
        }

        mutating func visitParagraph(_ paragraph: Paragraph) -> SwiftUI.Text {
            let text = defaultVisit(paragraph)
            if paragraph.hasSuccessor {
                return text + .init("\n\n")
            } else {
                return text
            }
        }

        mutating func visitLink(_ link: Markdown.Link) -> SwiftUI.Text {
            defaultVisit(link)
                .foregroundColor(.semantic.primary)
                .underline(true, color: .semantic.primary)
        }

        mutating func visitLineBreak(_ lineBreak: LineBreak) -> SwiftUI.Text {
            defaultVisit(lineBreak) + .init("\n\n")
        }

        mutating func visitSoftBreak(_ softBreak: SoftBreak) -> SwiftUI.Text {
            defaultVisit(softBreak) + .init("\n")
        }
    }
}

// swiftlint:disable switch_case_on_newline

extension Heading {

    var typography: Typography {
        switch level {
        case 0: .display
        case 1: .title1
        case 2: .title2
        case 3: .title3
        case 4: .subheading
        case 5: .body1
        case 6: .body2
        case 7: .paragraph1
        case 8: .paragraph2
        case 9: .caption1
        case 10: .caption2
        case 11: .overline
        case 12: .micro
        case _: .body1
        }
    }
}

extension Markup {

    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
}

struct RichText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                SwiftUI.Text(
                    rich: """
                    A

                    **B**
                    C
                    """
                )
            }
            Group {
                SwiftUI.Text(rich: "# Heading 1")
                SwiftUI.Text(rich: "## Heading 2")
                SwiftUI.Text(rich: "### Heading 3")
                SwiftUI.Text(rich: "#### Heading 4")
                SwiftUI.Text(rich: "##### Heading 5")
            }
            Group {
                SwiftUI.Text(rich: "The quick brown fox jumps over the lazy dog")
                SwiftUI.Text(rich: "*The quick brown fox jumps over the lazy dog*")
                SwiftUI.Text(rich: "**The quick brown fox jumps over the lazy dog**")
                SwiftUI.Text(rich: "_The quick brown fox jumps over the lazy dog_")
                SwiftUI.Text(rich: "The *quick* brown **fox** jumps _over_ the **lazy dog**")
            }
            Group {
                SwiftUI.Text(rich: "~~The quick brown fox jumps over the lazy dog~~")
                SwiftUI.Text(rich: "The quick [brown fox](www.google.com) jumps over the lazy dog")
            }
            Group {
                SwiftUI.Text(rich: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.")
            }
        }
        .typography(.body1)
        .padding()
    }
}
