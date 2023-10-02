// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: UIStackView {
    public var alignment: Binder<UIStackView.Alignment> {
        Binder(base) { stackView, alignment in
            stackView.alignment = alignment
        }
    }
}
