// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

enum LinkBankSplashScreenEffects {
    case closeFlow(_ isInteractive: Bool)
    case continueTapped
    case linkTapped(TitledLink)
}

protocol LinkBankSplashScreenRouting: ViewableRouting {
    func route(to path: LinkBankSplashScreen.Path)
}

protocol LinkBankSplashScreenPresentable: Presentable {
    func connect(state: Driver<LinkBankSplashScreenInteractor.State>) -> Driver<LinkBankSplashScreenEffects>
}

protocol LinkBankSplashScreenListener: AnyObject {
    func closeFlow(isInteractive: Bool)
    func route(to screen: LinkBankFlow.Screen)
}

final class LinkBankSplashScreenInteractor: PresentableInteractor<LinkBankSplashScreenPresentable>,
    LinkBankSplashScreenInteractable
{

    weak var router: LinkBankSplashScreenRouting?
    weak var listener: LinkBankSplashScreenListener?

    private let bankLinkageData: BankLinkageData
    private let contentReducer: LinkBankSplashScreenContentReducer
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        presenter: LinkBankSplashScreenPresentable,
        bankLinkageData: BankLinkageData,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        contentReducer: LinkBankSplashScreenContentReducer
    ) {

        self.bankLinkageData = bankLinkageData
        self.contentReducer = contentReducer
        self.analyticsRecorder = analyticsRecorder
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbBankLinkSplashSeen(partner: partnerForAnalytics()))

        let state = Driver.of(
            contentReducer.reduce(for: bankLinkageData.partner)
        )

        presenter.connect(state: state)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    private func handle(effect: LinkBankSplashScreenEffects) {
        switch effect {
        case .closeFlow(let isInteractive):
            listener?.closeFlow(isInteractive: isInteractive)
        case .continueTapped:
            analyticsRecorder.record(
                event: AnalyticsEvents.SimpleBuy.sbBankLinkSplashCTA(partner: partnerForAnalytics())
            )
            switch bankLinkageData.partner {
            case .yapily:
                listener?.route(to: .yapily(data: bankLinkageData))
            case .yodlee:
                listener?.route(to: .yodlee(data: bankLinkageData))
            }
        case .linkTapped(let link):
            router?.route(to: .link(url: link.url))
        }
    }

    private func partnerForAnalytics() -> AnalyticsEvents.SimpleBuy.LinkedBankPartner {
        bankLinkageData.partner == .yodlee ? .ach : .ob
    }
}

extension LinkBankSplashScreenInteractor {
    struct State {
        var topTitle: LabelContent
        var topSubtitle: LabelContent
        var partnerLogoImageContent: ImageViewContent
        var detailsTitle: LabelContent
        var detailsInteractiveTextModel: InteractableTextViewModel
        var continueButtonModel: ButtonViewModel
    }
}

extension LinkBankSplashScreenInteractor.State {
    mutating func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }
}

final class LinkBankSplashScreenContentReducer {

    typealias State = LinkBankSplashScreenInteractor.State
    typealias LocalizedStrings = LocalizationConstants.SimpleBuy.LinkBankScreen

    func reduce(for partner: BankLinkageData.Partner) -> State {
        switch partner {
        case .yodlee:
            return contentForYodlee(with: partner.title)
        case .yapily:
            fatalError("yapily is not yet supported")
        }
    }

    func contentForYodlee(with partnerName: String) -> State {
        let topTitleContent = LabelContent(
            text: LocalizedStrings.title,
            font: .main(.bold, 20),
            color: .darkTitleText,
            alignment: .left
        )

        let topSubtitleContent = LabelContent(
            text: String(format: LocalizedStrings.subtitle, partnerName),
            font: .main(.regular, 14),
            color: .darkTitleText,
            alignment: .left
        )

        let partnerLogoImageContent = ImageViewContent(
            imageResource: .local(name: "yodlee-logo", bundle: .platformUIKit)
        )

        let detailsTitleContent = LabelContent(
            text: String(format: LocalizedStrings.detailsTitle, partnerName),
            font: .main(.semibold, 14),
            color: .darkTitleText,
            alignment: .center
        )

        let detailsSubtitle = String(format: LocalizedStrings.detailsSubtitle, partnerName)
        let yodleeSecurityLink = "https://www.yodlee.com/legal/yodlee-security"
        let detailsInteractiveTextModel = InteractableTextViewModel(
            inputs: [
                InteractableTextViewModel.Input.text(string: detailsSubtitle + "\n"),
                InteractableTextViewModel.Input.url(string: LocalizedStrings.learnMore, url: yodleeSecurityLink)
            ],
            textStyle: InteractableTextViewModel.Style(color: .descriptionText, font: .main(.regular, 12)),
            linkStyle: InteractableTextViewModel.Style(color: .linkableText, font: .main(.medium, 12)),
            alignment: .center
        )

        let continueButtonModel = ButtonViewModel.primary(with: LocalizedStrings.continueButtonTitle)

        return State(
            topTitle: topTitleContent,
            topSubtitle: topSubtitleContent,
            partnerLogoImageContent: partnerLogoImageContent,
            detailsTitle: detailsTitleContent,
            detailsInteractiveTextModel: detailsInteractiveTextModel,
            continueButtonModel: continueButtonModel
        )
    }
}
