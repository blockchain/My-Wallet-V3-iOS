// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift

final class BanksSectionPresenter: SettingsSectionPresenting {

    let sectionType: SettingsSectionType = .banks

    let state: Observable<SettingsSectionLoadingState>

    // MARK: - Private Properties

    private let addPaymentMethodCellPresenters: [AddPaymentMethodCellPresenter]
    private let interactor: BanksSettingsSectionInteractor

    // MARK: - Setup

    init(interactor: BanksSettingsSectionInteractor, app: AppProtocol = resolve()) {
        self.interactor = interactor
        let addPaymentMethodCellPresenters = interactor.addPaymentMethodInteractors
            .map {
                AddPaymentMethodCellPresenter(interactor: $0)
            }

        self.addPaymentMethodCellPresenters = addPaymentMethodCellPresenters

        let sectionType = sectionType
        self.state = interactor.state
            .flatMap { [app] state -> Observable<SettingsSectionLoadingState> in
                switch state {
                case .invalid:
                    return .just(.loaded(next: .empty))
                case .calculating:
                    let cells = [SettingsCellViewModel(cellType: .banks(.skeleton(0)))]
                    return .just(.loaded(next: .some(.init(sectionType: sectionType, items: cells))))
                case .value(let data):
                    let isAbleToAddNew = addPaymentMethodCellPresenters.map(\.isAbleToAddNew)
                    return Observable.zip(
                        Observable.zip(isAbleToAddNew),
                        app.publisher(for: blockchain.app.is.external.brokerage, as: Bool.self).replaceError(with: false).asObservable()
                    )
                    .take(1)
                    .map { isAbleToAddNew, isExternalBrokerage -> [SettingsCellViewModel] in
                        let presenters = zip(isAbleToAddNew, addPaymentMethodCellPresenters)
                            .filter(\.0)
                            .map(\.1)

                        if !data.isEmpty, isExternalBrokerage {
                            return Array(data)
                        } else {
                            return Array(data) + Array(presenters)
                        }
                    }
                    .map { viewModels in
                        guard !viewModels.isEmpty else {
                            return .loaded(next: .empty)
                        }
                        let sectionViewModel = SettingsSectionViewModel(
                            sectionType: sectionType,
                            items: viewModels
                        )
                        return .loaded(next: .some(sectionViewModel))
                    }
                }
            }
            .share(replay: 1, scope: .whileConnected)
    }
}

extension [SettingsCellViewModel] {
    fileprivate init(_ presenters: [AddPaymentMethodCellPresenter]) {
        self = presenters
            .map { SettingsCellViewModel(cellType: .banks(.add($0))) }
    }

    fileprivate init(_ viewModels: [BeneficiaryLinkedBankViewModel]) {
        self = viewModels
            .map {
                SettingsCellViewModel(cellType: .banks(.linked($0)))
            }
    }

    fileprivate init(_ beneficiaries: [Beneficiary]) {
        self = beneficiaries
            .map {
                SettingsCellViewModel(cellType: .banks(.linked(BeneficiaryLinkedBankViewModel(data: $0))))
            }
    }
}
