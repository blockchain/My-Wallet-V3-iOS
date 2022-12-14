// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

struct SecurePinViewModel {

    // MARK: - Properties

    let emptyPinColor: UIColor
    let tint: UIColor
    let title: String
    let emptyScaleRatio: CGFloat = 0.667
    let joltOffset: CGFloat = 50

    // MARK: - Rx

    /// Observes count and streams it
    let fillCountRelay = BehaviorRelay<Int>(value: 0)
    var fillCount: Observable<Int> {
        fillCountRelay
            .observe(on: MainScheduler.instance)
            .asObservable()
    }

    // MARK: - Setup

    init(title: String, tint: UIColor, emptyPinColor: UIColor) {
        self.title = title
        self.tint = tint
        self.emptyPinColor = emptyPinColor
    }
}
