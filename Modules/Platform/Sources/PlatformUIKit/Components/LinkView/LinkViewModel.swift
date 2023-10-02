// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import RxCocoa
import RxRelay
import RxSwift

/// A view model for `LinkView` which is able to display a link embedded in text,
/// leveraging `InteractableTextViewModel` to do so.
public final class LinkViewModel {

    // MARK: - Types

    public struct Text: Equatable {
        public let prefix: String
        public let button: String

        public static var empty: Text {
            .init(prefix: "", button: "")
        }

        public init(prefix: String, button: String) {
            self.prefix = prefix
            self.button = button
        }
    }

    private enum Constant {
        static let tapUrl = "tap"
    }

    // MARK: - Exposed Properties

    /// Able to observe and accept `Text` elements
    public let textRelay = BehaviorRelay<Text>(value: .empty)

    /// Streams link taps
    public var tap: Observable<Void> {
        textViewModel.tap
            .mapToVoid()
    }

    var textDidChange: Observable<Void> {
        textDidChangeRelay.asObservable()
    }

    private let textDidChangeRelay = PublishRelay<Void>()

    let textViewModel: InteractableTextViewModel

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        font: UIFont = .main(.medium, 14),
        textColor: UIColor = .mutedText,
        linkColor: UIColor = .primary
    ) {
        self.textViewModel = InteractableTextViewModel(
            inputs: [],
            textStyle: .init(color: textColor, font: font),
            linkStyle: .init(color: linkColor, font: font)
        )
        textRelay
            .distinctUntilChanged()
            .map { text in
                [
                    .text(string: text.prefix),
                    .url(string: text.button, url: Constant.tapUrl)
                ]
            }
            .bindAndCatch(to: textViewModel.inputsRelay)
            .disposed(by: disposeBag)

        textViewModel.inputsRelay
            .mapToVoid()
            .bindAndCatch(to: textDidChangeRelay)
            .disposed(by: disposeBag)
    }
}
