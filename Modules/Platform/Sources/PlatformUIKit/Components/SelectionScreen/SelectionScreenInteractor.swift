// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class SelectionScreenInteractor {

    // MARK: - Properties

    private let interactorsRelay = BehaviorRelay<[SelectionItemViewInteractor]>(value: [])
    var interactors: Observable<[SelectionItemViewInteractor]> {
        _ = setup
        return interactorsRelay.asObservable()
    }

    public var selectedIdOnDismissal: Single<String> {
        selectionOnDismissalRelay
            .take(1)
            .asSingle()
            .map(\.id)
    }

    public var dismiss: Observable<Void> {
        dissmisRelay.asObservable()
    }

    let dissmisRelay = PublishRelay<Void>()

    private let selectionOnDismissalRelay = PublishRelay<SelectionItemViewModel>()

    // MARK: - Injected

    let service: SelectionServiceAPI

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    private lazy var setup: Void = service.dataSource
        .map(weak: self) { (self, items) in
            items
                .map { item in
                    SelectionItemViewInteractor(
                        item: item,
                        service: self.service
                    )
                }
        }
        .bindAndCatch(to: interactorsRelay)
        .disposed(by: disposeBag)

    // MARK: - Setup

    public init(service: SelectionServiceAPI) {
        self.service = service
    }

    func recordSelection() {
        service.selectedDataRelay
            .bindAndCatch(to: selectionOnDismissalRelay)
            .disposed(by: disposeBag)
    }
}
