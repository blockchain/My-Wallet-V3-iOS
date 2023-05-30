// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxRelay
import RxSwift

public struct TitledLink: Equatable {
    public let title: String
    public let url: URL
}

/// A view model for `InteractableTextView`
public struct InteractableTextViewModel {
    public static let empty = InteractableTextViewModel(
        inputs: [],
        textStyle: .init(color: .semantic.body, font: .main(.medium, 14.0)),
        linkStyle: .init(color: .semantic.primary, font: .main(.bold, 14.0))
    )

    /// A style for text or link
    public struct Style {
        public let color: Color
        public let font: UIFont

        public init(color: Color, font: UIFont) {
            self.color = color
            self.font = font
        }
    }

    /// An input with either a url or a string.
    /// Each input is formatted according to its nature
    public enum Input: Equatable {
        /// A linkable url string
        case url(string: String, url: String)

        /// A regular string
        case text(string: String)

        var stringValue: String {
            switch self {
            case .url(string: let value, url: _):
                return value
            case .text(string: let value):
                return value
            }
        }
    }

    public var identifier: String {
        inputsRelay
            .value
            .map(\.stringValue)
            .joined(separator: ".")
    }

    /// Steams the url upon each tap
    public var tap: Observable<TitledLink> {
        tapRelay.asObservable()
    }

    /// Relay that accepts and streams the array of inputs
    public let inputsRelay = BehaviorRelay<[Input]>(value: [])

    let textStyle: Style
    let linkStyle: Style
    let alignment: NSTextAlignment
    let lineSpacing: CGFloat

    let tapRelay = PublishRelay<TitledLink>()

    public init(
        inputs: [Input],
        textStyle: Style,
        linkStyle: Style,
        lineSpacing: CGFloat = 0,
        alignment: NSTextAlignment = .natural
    ) {
        inputsRelay.accept(inputs)
        self.textStyle = textStyle
        self.linkStyle = linkStyle
        self.lineSpacing = lineSpacing
        self.alignment = alignment
    }
}

extension InteractableTextViewModel: Equatable {
    public static func == (lhs: InteractableTextViewModel, rhs: InteractableTextViewModel) -> Bool {
        lhs.inputsRelay.value == rhs.inputsRelay.value
    }
}

extension Reactive where Base: InteractableTextView {
    public var viewModel: Binder<InteractableTextViewModel> {
        Binder(base) { $0.viewModel = $1 }
    }
}
