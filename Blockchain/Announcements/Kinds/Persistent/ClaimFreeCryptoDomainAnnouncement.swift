// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureCryptoDomainDomain
import Localization
import PlatformUIKit
import RxSwift
import ToolKit

final class ClaimFreeCryptoDomainAnnouncement: PersistentAnnouncement, ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.ClaimFreeDomain

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.button,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardActioned(type: .claimFreeCryptoDomain)
                )
                action()
                dismiss()
            }
            .disposed(by: disposeBag)
        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-unstoppable", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardDismissed(type: .claimFreeCryptoDomain)
                )
                dismiss()
            },
            didAppear: { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardShown(type: .claimFreeCryptoDomain)
                )
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        claimFreeDomainEligible
    }

    let type = AnnouncementType.claimFreeCryptoDomain
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    private let claimFreeDomainEligible: Bool
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        claimFreeDomainEligible: Bool,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.action = action
        self.dismiss = dismiss
        self.claimFreeDomainEligible = claimFreeDomainEligible
    }
}
