//
//  AaveYfiDotAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 30/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Announcement that introduces Aave Yfi Dot assets
final class AaveYfiDotAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.AaveYfiDot
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "yfi_aave_dot_announcement", size: CGSize(width: 140, height: 40)),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }
    
    var shouldShow: Bool {
        !isDismissed
    }
    
    let type = AnnouncementType.aaveYfiDot
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()
    
    // MARK: - Setup

    init(cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
