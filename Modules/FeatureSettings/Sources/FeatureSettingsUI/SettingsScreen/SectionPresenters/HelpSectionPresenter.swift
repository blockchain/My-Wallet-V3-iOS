// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class HelpSectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .help
    var state: Observable<SettingsSectionLoadingState>

    init() {
        self.state = .just(
            .loaded(next:
                .some(
                    .init(
                        sectionType: sectionType,
                        items: [
                            .init(cellType: .common(.contactSupport)),
                            .init(cellType: .common(.rateUs)),
                            .init(cellType: .common(.termsOfService)),
                            .init(cellType: .common(.privacyPolicy)),
                            .init(cellType: .common(.cookiesPolicy)),
                            .init(cellType: .common(.logout))
                        ]
                    )
                )
            )
        )
    }
}
