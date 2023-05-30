// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

struct TableHeaderViewModel {

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

    /// - parameter cornerRadius: corner radius of the component
    init(font: UIFont = .main(.medium, 12), title: String, textColor: UIColor) {
        self.font = font
        textRelay.accept(title)
        contentColorRelay.accept(textColor)
    }
}

extension TableHeaderViewModel {
    static func settings(title: String) -> TableHeaderViewModel {
        .init(font: .main(.semibold, 20), title: title, textColor: .semantic.body)
    }
}
