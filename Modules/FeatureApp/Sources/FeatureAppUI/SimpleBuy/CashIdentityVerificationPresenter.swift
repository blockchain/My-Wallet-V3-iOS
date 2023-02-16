// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final public class CashIdentityVerificationPresenter {

    private typealias LocalizationId = LocalizationConstants.SimpleBuy.CashIntroductionScreen

    enum CellType {
        case announcement(AnnouncementCardViewModel)
        case numberedItem(BadgeNumberedItemViewModel)
        case buttons([ButtonViewModel])
    }

    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }

    let cellArrangement: [CellType]

    let announcement: AnnouncementCardViewModel
    let notNowButtonViewModel: ButtonViewModel
    let verifyIdentityButtonViewModel: ButtonViewModel
    let badgeNumberedItemViewModels: [BadgeNumberedItemViewModel]

    private let router: CashIdentityVerificationRouterAPI
    private let disposeBag = DisposeBag()

    public init(router: CashIdentityVerificationRouterAPI = resolve()) {
        self.router = router
        self.badgeNumberedItemViewModels = [
            .init(
                number: 1,
                title: LocalizationId.List.First.title,
                description: LocalizationId.List.First.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "1")
            ),
            .init(
                number: 2,
                title: LocalizationId.List.Second.title,
                description: LocalizationId.List.Second.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "2")
            ),
            .init(
                number: 3,
                title: LocalizationId.List.Third.title,
                description: LocalizationId.List.Third.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "3")
            )
        ]
        self.announcement = .init(
            badgeImage: .init(
                image: .local(name: "icon-gbp", bundle: .platformUIKit),
                contentColor: .white,
                backgroundColor: .fiat,
                cornerRadius: .roundedLow,
                size: .edge(32)
            ),
            border: .none,
            title: LocalizationId.title,
            description: LocalizationId.description,
            dismissState: .undismissible
        )

        self.notNowButtonViewModel = .secondary(with: LocalizationId.notNow)
        self.verifyIdentityButtonViewModel = .primary(with: LocalizationId.verifyIdentity)

        let badgedNumberedItems: [CellType] = badgeNumberedItemViewModels.map { .numberedItem($0) }
        self.cellArrangement =
            [.announcement(announcement)]
                + badgedNumberedItems
                + [.buttons([notNowButtonViewModel, verifyIdentityButtonViewModel])]

        notNowButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.router.dismiss()
            }
            .disposed(by: disposeBag)

        verifyIdentityButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.router.dismiss(startKYC: true)
            }
            .disposed(by: disposeBag)
    }
}
