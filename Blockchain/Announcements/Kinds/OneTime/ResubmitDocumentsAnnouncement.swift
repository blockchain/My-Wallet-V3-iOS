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

/// Let the user know that something went wrong during KYC, and that he needs to send his docs once more
final class ResubmitDocumentsAnnouncement: OneTimeAnnouncement, ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.ResubmitDocuments.ctaButton
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
                image: .local(name: "card-icon-v", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizationConstants.AnnouncementCards.ResubmitDocuments.title,
            description: LocalizationConstants.AnnouncementCards.ResubmitDocuments.description,
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
        needsDocumentResubmission && !isDismissed
    }

    let type = AnnouncementType.resubmitDocuments
    let analyticsRecorder: AnalyticsEventRecorderAPI

    var dismiss: CardAnnouncementAction
    var recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let needsDocumentResubmission: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        needsDocumentResubmission: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        self.needsDocumentResubmission = needsDocumentResubmission
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct ResubmitDocumentsAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = ResubmitDocumentsAnnouncement(
            needsDocumentResubmission: true,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct ResubmitDocumentsAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResubmitDocumentsAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
