// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import WalletPayloadKit

public final class WalletUpgradePresenter {

    // MARK: Properties

    var viewModel: Driver<WalletUpgradeViewModel> {
        viewModelRelay.asDriver()
    }

    // MARK: Private Properties

    private let viewModelRelay = BehaviorRelay<WalletUpgradeViewModel>(value: .loading(version: nil))
    private let interactor: WalletUpgradeInteractor
    private let disposeBag = DisposeBag()

    // MARK: Init

    public init(interactor: WalletUpgradeInteractor) {
        self.interactor = interactor
    }

    private lazy var viewDidAppearOnce: Void = interactor.upgradeWallet()
        .subscribe(
            onNext: { [weak self] version in
                self?.viewModelRelay.accept(.loading(version: version))
            },
            onError: { [weak self] error in
                let version: String
                switch error {
                case WalletUpgradeError.errorUpgrading(let errorVersion):
                    version = errorVersion
                default:
                    version = ""
                }
                self?.viewModelRelay.accept(.error(version: version))
            },
            onCompleted: { [weak self] in
                self?.viewModelRelay.accept(.success)
            }
        )
        .disposed(by: disposeBag)

    // MARK: Methods

    func viewDidAppear() {
        _ = viewDidAppearOnce
    }
}
