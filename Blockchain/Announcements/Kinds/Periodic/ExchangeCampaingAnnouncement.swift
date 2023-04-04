import AnalyticsKit
import DIKit
import FeatureCryptoDomainDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class ExchangeCampaingAnnouncement: PeriodicAnnouncement, ActionableAnnouncement {
    // MARK: - Types

    private typealias L10n = LocalizationConstants.AnnouncementCards.WalletAwareness

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: L10n.button,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.WalletAwareness.promptActioned(isSSOUser: user.isSSO)
                )
                markDismissed()
                action()
                dismiss()
            }
            .disposed(by: disposeBag)
        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "exchange-announcement-icon", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(32)
            ),
            background: .init(imageName: "exchange-announcement-background"),
            title: L10n.title,
            description: L10n.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.WalletAwareness.promptDismissed(isSSOUser: user.isSSO)
                )
                markDismissed()
                dismiss()
            },
            didAppear: { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(
                    event: AnalyticsEvents.WalletAwareness.promptShown(
                        isSSOUser: user.isSSO,
                        countOfPrompts: dismissalsSoFar + 1
                    )
                )
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        isEnabled && !isDismissed
    }

    let type = AnnouncementType.exchangeCampaign
    let appearanceRules: PeriodicAnnouncementAppearanceRules
    let recorder: AnnouncementRecorder
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let isEnabled: Bool
    private let cohort: Int?
    private let user: NabuUser

    // MARK: - Setup

    init(
        isEnabled: Bool,
        cohort: Int?,
        user: NabuUser,
        cacheSuite: CacheSuite = resolve(),
        reappearanceTimeInterval: TimeInterval,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.isEnabled = isEnabled
        self.cohort = cohort
        self.user = user
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.analyticsRecorder = analyticsRecorder
        self.action = action
        self.dismiss = dismiss
    }
}
