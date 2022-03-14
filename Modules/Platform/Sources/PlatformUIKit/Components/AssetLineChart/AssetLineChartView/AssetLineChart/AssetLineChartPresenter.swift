// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import ComposableNavigation
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// A presentation layer for asset line chart
public final class AssetLineChartPresenter {

    // MARK: - Properties

    /// The size of the line chart as derivative of the edge
    public var size: CGSize {
        CGSize(width: edge, height: edge)
    }

    /// Streams the state of pie-chart
    public var state: Observable<AssetLineChart.State.Presentation> {
        _ = setup
        return stateRelay
            .observe(on: MainScheduler.instance)
    }

    private lazy var setup: Void = interactor
        .state
        .map { .init(with: $0) }
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

    private let edge: CGFloat
    private let interactor: AssetLineChartInteracting

    /// The state relay. Starts with a `.loading` state
    private let stateRelay = BehaviorRelay<AssetLineChart.State.Presentation>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        edge: CGFloat,
        interactor: AssetLineChartInteracting
    ) {
        self.edge = edge
        self.interactor = interactor
    }
}
