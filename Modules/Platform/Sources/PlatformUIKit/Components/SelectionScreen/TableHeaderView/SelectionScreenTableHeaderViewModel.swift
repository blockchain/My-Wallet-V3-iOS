// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public struct SelectionScreenTableHeaderViewModel {

    /// The content color relay
    let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)

    /// The content color of the title
    var contentColor: Driver<UIColor> {
        contentColorRelay.asDriver()
    }

    /// The text relay
    let textRelay = BehaviorRelay<String>(value: "")

    /// Text to be displayed on the badge
    var text: Driver<String> {
        textRelay.asDriver()
    }

    let font: UIFont

    public init?(font: UIFont = .main(.medium, 14), title: String?, textColor: UIColor = .semantic.text) {
        guard let title else { return nil }
        self.font = font
        textRelay.accept(title)
        contentColorRelay.accept(textColor)
    }
}
