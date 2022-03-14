// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import RxCocoa
import RxRelay
import RxSwift

/// A presentation layer for asset pie chart
public final class AssetPieChartPresenter {

    // MARK: - Properties

    /// The size of the pie chart as derivative of the edge
    var size: CGSize {
        CGSize(width: edge, height: edge)
    }

    /// Streams the state of pie-chart
    var state: Observable<AssetPieChart.State.Presentation> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
    }

    private lazy var setup: Void = interactor.state
        .map { .init(with: $0) }
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let edge: CGFloat
    private let interactor: AssetPieChartInteracting

    /// The state relay. Starts with a `.loading` state
    private let stateRelay = BehaviorRelay<AssetPieChart.State.Presentation>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        edge: CGFloat,
        interactor: AssetPieChartInteracting
    ) {
        self.edge = edge
        self.interactor = interactor
    }

    public func refresh() {
        interactor.refresh()
    }
}
