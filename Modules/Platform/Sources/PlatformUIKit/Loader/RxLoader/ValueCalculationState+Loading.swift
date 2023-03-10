// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

extension ValueCalculationState {
    public func handle(loadingViewPresenter: LoadingViewPresenting, text: String? = nil) {
        switch self {
        case .calculating, .invalid(.empty):
            loadingViewPresenter.showCircular(with: text)
        case .invalid(.valueCouldNotBeCalculated), .value, .invalid(.ux):
            loadingViewPresenter.hide()
        }
    }
}

extension ObservableType {
    public func handle<Value>(
        loadingViewPresenter: LoadingViewPresenting,
        text: String? = nil
    ) -> Observable<ValueCalculationState<Value>> where Element == ValueCalculationState<Value> {
        self.do(
            onNext: { state in
                state.handle(loadingViewPresenter: loadingViewPresenter, text: text)
            }
        )
    }
}
