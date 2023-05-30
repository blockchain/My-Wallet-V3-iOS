// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitectureExtensions
import PlatformKit
import RxSwift
import UIKit

extension LabelContent {
    public enum State {
        /// The state of the `LabelItem` interactor and presenter
        public typealias Interaction = LoadingState<LabelContent.Value.Interaction.Content>
        public typealias Presentation = LoadingState<LabelContent.Value.Presentation.Content>
    }

    public enum Value {
        public enum Interaction {}
        public enum Presentation {}
    }
}

extension ObservableType where Element == String {

    public func mapToLabelContentStateInteraction() -> Observable<LabelContent.State.Interaction> {
        map { string in
            .loaded(next: .init(text: string))
        }
    }
}

extension ObservableType where Element == String? {

    public func mapToLabelContentStateInteraction() -> Observable<LabelContent.State.Interaction> {
        map {
            guard let element = $0 else {
                return .loading
            }
            return .loaded(next: .init(text: element))
        }
    }
}

extension LabelContent.Value.Interaction {

    public struct Content {
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }
}

extension LabelContent.Value.Presentation {

    public struct Content {

        /// Descriptors that allows customized content and style
        public struct Descriptors {

            let fontWeight: FontWeight
            let contentColor: UIColor
            let fontSize: CGFloat
            let lineSpacing: CGFloat
            let lineBreakMode: NSLineBreakMode
            let accessibility: Accessibility

            public init(
                fontWeight: FontWeight = .medium,
                contentColor: UIColor = .semantic.title,
                fontSize: CGFloat,
                lineSpacing: CGFloat = 1,
                lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                accessibility: Accessibility
            ) {
                self.fontWeight = fontWeight
                self.contentColor = contentColor
                self.fontSize = fontSize
                self.lineSpacing = lineSpacing
                self.lineBreakMode = lineBreakMode
                self.accessibility = accessibility
            }
        }

        public let labelContent: LabelContent

        public init(with value: LabelContent.Value.Interaction.Content, descriptors: Descriptors) {
            self.labelContent = LabelContent(
                text: value.text,
                font: .main(descriptors.fontWeight, descriptors.fontSize),
                color: descriptors.contentColor,
                lineBreakMode: descriptors.lineBreakMode,
                accessibility: descriptors.accessibility
            )
        }
    }
}

extension LabelContent.Value.Presentation.Content.Descriptors {
    /// Returns a descriptor for a disclaimer in a `Settings` cell.
    public static func disclaimer(
        accessibilityId: String
    ) -> LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            fontSize: 12,
            accessibility: .id(accessibilityId)
        )
    }

    public static func body(
        accessibilityId: String
    ) ->
        LabelContent.Value.Presentation.Content.Descriptors
    {
        .init(
            fontWeight: .medium,
            contentColor: .semantic.title,
            fontSize: 14,
            lineSpacing: 1.18,
            accessibility: .id(accessibilityId)
        )
    }

    public static func lineItemTitle(
        accessibilityIdPrefix: String
    ) -> LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            fontWeight: .medium,
            contentColor: .semantic.title,
            fontSize: 14,
            accessibility: .id("\(accessibilityIdPrefix).title")
        )
    }

    public static func lineItemDescription(
        accessibilityIdPrefix: String
    ) -> LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            fontWeight: .semibold,
            contentColor: .semantic.body,
            fontSize: 16,
            accessibility: .id("\(accessibilityIdPrefix).description")
        )
    }

    public static func h1(
        accessibilityIdPrefix: String
    ) -> LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            fontWeight: .semibold,
            fontSize: 32,
            accessibility: .id("\(accessibilityIdPrefix).title")
        )
    }

    public static func success(
        fontSize: CGFloat,
        accessibility: Accessibility
    ) -> LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            contentColor: .positivePrice,
            fontSize: fontSize,
            accessibility: accessibility
        )
    }
}

extension LoadingState where Content == LabelContent.Value.Presentation.Content {
    public init(
        with state: LoadingState<LabelContent.Value.Interaction.Content>,
        descriptors: LabelContent.Value.Presentation.Content.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(next: Content(with: content, descriptors: descriptors))
        }
    }
}
