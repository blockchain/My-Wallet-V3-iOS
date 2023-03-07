// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIComponentsKit

public final class InterestAccountDetailsScreenPresenter {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails
    private typealias AccessibilityId = Accessibility.Identifier.Interest.Dashboard.InterestDetails

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .close
    }

    var leadingButton: Screen.Style.LeadingButton {
        .none
    }

    var titleView: Screen.Style.TitleView {
        .text(value: interactor.cryptoCurrency.name)
    }

    var barStyle: Screen.Style.Bar {
        .lightContent()
    }

    var sectionObservable: Observable<[DetailSectionViewModel]> {
        Observable
            .zip(items, buttons.asObservable())
            .map { $0.0 + $0.1 }
            .map { $0.map { presenter in DetailCellViewModel(presenter: presenter) } }
            .map { [DetailSectionViewModel(identifier: "", items: $0)] }
    }

    private var items: Observable<[DetailCellPresenter]> {
        interactor
            .interactors
            .map { interactors -> [DetailCellPresenter] in
                interactors.enumerated().map { [unowned self] index, interactor in
                    switch interactor {
                    case .balance(let balanceCellInteractor):
                        let presenter: CurrentBalanceCellPresenter = .init(
                            interactor: balanceCellInteractor,
                            descriptionValue: { .just(LocalizationId.Cell.Balance.title) },
                            currency: .crypto(self.interactor.cryptoCurrency),
                            viewAccessibilitySuffix: "\(AccessibilityId.view)",
                            titleAccessibilitySuffix: "\(AccessibilityId.balanceCellTitle)",
                            descriptionAccessibilitySuffix: "\(AccessibilityId.balanceCellDescription)",
                            pendingAccessibilitySuffix: "\(AccessibilityId.balanceCellPending)",
                            descriptors: .default(
                                cryptoAccessiblitySuffix: "\(AccessibilityId.balanceCellCryptoAmount)",
                                fiatAccessiblitySuffix: "\(AccessibilityId.balanceCellFiatAmount)"
                            )
                        )
                        return .currentBalance(presenter)
                    case .item(let line):
                        switch line {
                        case .default(let interactor):
                            return .lineItem(
                                .default(
                                    .init(
                                        interactor: interactor,
                                        accessibilityIdPrefix: "\(AccessibilityId.lineItem).\(index)",
                                        identifier: "\(index)"
                                    )
                                )
                            )
                        }
                    }
                }
            }
    }

    private var buttons: Single<[DetailCellPresenter]> {
        Single.zip(
            interactor.canDeposit,
            interactor.canWithdraw
        )
        .map { [primaryButtonViewModel, secondaryButtonViewModel] canDeposit, canWithdraw in
            var values: [ButtonViewModel] = []
            if canWithdraw {
                values.append(secondaryButtonViewModel)
            }
            if canDeposit {
                values.append(primaryButtonViewModel)
            }
            return [.buttons(values)]
        }
    }

    private let app: AppProtocol
    private let primaryButtonViewModel: ButtonViewModel
    private let secondaryButtonViewModel: ButtonViewModel
    private let interactor: InterestAccountDetailsScreenInteractor
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let tabSwapping: TabSwapping
    private let disposeBag = DisposeBag()
    private var bag = Set<AnyCancellable>()

    public init(
        app: AppProtocol = resolve(),
        tabSwapping: TabSwapping = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        interactor: InterestAccountDetailsScreenInteractor
    ) {
        self.app = app
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.tabSwapping = tabSwapping
        self.interactor = interactor
        let code = interactor.cryptoCurrency.displayCode

        self.primaryButtonViewModel = .primary(with: LocalizationId.add + " \(code)")
        self.secondaryButtonViewModel = .secondary(with: LocalizationId.withdraw + " \(code)")

        primaryButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self, _) in
                self.dismiss { [tabSwapping, interactor] in
                    tabSwapping.interestTransfer(into: interactor.account)
                }
            }
            .disposed(by: disposeBag)

        secondaryButtonViewModel
            .tapRelay
            .flatMap { _ in interactor.target }
            .bindAndCatch(weak: self) { (self, target) in
                self.dismiss { [tabSwapping, interactor] in
                    tabSwapping.interestWithdraw(from: interactor.account, target: target)
                }
            }
            .disposed(by: disposeBag)
    }

    /// Dismiss all presented ViewControllers and then execute callback.
    private func dismiss(completion: @escaping (() -> Void)) {
        func _dismiss(completion: @escaping (() -> Void)) {
            var root: UIViewController? = topMostViewControllerProvider.topMostViewController
            while root?.presentingViewController != nil {
                root = root?.presentingViewController
            }
            root?
                .dismiss(
                    animated: true,
                    completion: {
                        completion()
                    }
                )
        }

        app.publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .map(\.value)
            .replaceNil(with: false)
            .ignoreFailure()
            .sink { isSuperAppEnabled in
                if isSuperAppEnabled {
                    completion()
                } else {
                    _dismiss(completion: completion)
                }
            }
            .store(in: &bag)
    }
}
