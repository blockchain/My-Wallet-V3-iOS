// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

final class SimpleBuyFinishSignupAnnouncement: PeriodicAnnouncement, ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.SimpleBuyFinishSignup

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: actionAnalyticsEvent)
                action()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-v", bundle: .main),
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
                analyticsRecorder.record(event: dismissAnalyticsEvent)
                dismiss()
            },
            didAppear: { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: didAppearAnalyticsEvent)
            }
        )
    }

    var associatedAppModes: [AppMode] {
        [AppMode.trading, AppMode.universal]
    }

    var shouldShow: Bool {
        hasIncompleteBuyFlow && canCompleteVerified
    }

    let type = AnnouncementType.simpleBuyKYCIncomplete
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let appearanceRules: PeriodicAnnouncementAppearanceRules

    let action: CardAnnouncementAction

    private let hasIncompleteBuyFlow: Bool
    private let canCompleteVerified: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        canCompleteVerified: Bool,
        hasIncompleteBuyFlow: Bool,
        cacheSuite: CacheSuite = resolve(),
        reappearanceTimeInterval: TimeInterval,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.canCompleteVerified = canCompleteVerified
        self.hasIncompleteBuyFlow = hasIncompleteBuyFlow
        self.action = action
        self.dismiss = dismiss
        self.analyticsRecorder = analyticsRecorder
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct SimpleBuyFinishSignupAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = SimpleBuyFinishSignupAnnouncement(
            canCompleteVerified: true,
            hasIncompleteBuyFlow: true,
            reappearanceTimeInterval: 0,
            action: {},
            dismiss: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct SimpleBuyFinishSignupAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleBuyFinishSignupAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
