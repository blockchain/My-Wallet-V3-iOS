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

/// This announcement informs the user that View NFT support
/// is coming soon to mobile and they can be informed of when
/// support is live by tapping `Join Waitlist`
final class ViewNFTComingSoonAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.ViewNFT

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.buttonTitle,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: actionAnalyticsEvent)
                markRemoved()
                action()
                dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "nft-icon", bundle: .main),
                contentColor: .nftBadge,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: CGSize(width: 35, height: 40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self else { return }
                analyticsRecorder.record(event: dismissAnalyticsEvent)
                markRemoved()
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
        !isDismissed
    }

    let type = AnnouncementType.viewNFTWaitlist
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct ViewNFTComingSoonAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = ViewNFTComingSoonAnnouncement(dismiss: {}, action: {})
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct ViewNFTComingSoonAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewNFTComingSoonAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 200))
    }
}
#endif
