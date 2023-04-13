// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

enum YodleeScreen {
    enum Action: Equatable {
        case pending(content: YodleePendingContent)
        case success(content: YodleePendingContent)
        case failure(content: YodleePendingContent)
        case load(request: URLRequest)
        case none

        var request: URLRequest? {
            switch self {
            case .load(let request):
                return request
            default:
                return nil
            }
        }

        var content: YodleePendingContent? {
            switch self {
            case .pending(let content),
                 .failure(let content),
                 .success(let content):
                return content
            default:
                return nil
            }
        }
    }

    enum Effect: Equatable {
        case link(url: URL)
        case closeFlow(_ isInteractive: Bool)
        case back
        case none
    }
}

protocol YodleeScreenRouting: ViewableRouting {
    func route(to path: YodleeRoute.Path)
}

protocol YodleeScreenPresentable: Presentable {
    func connect(action: Driver<YodleeScreen.Action>) -> Driver<YodleeScreen.Effect>
}

public protocol LinkBankListener: AnyObject {
    func closeFlow(isInteractive: Bool)
    func returnToSplashScreen()
    func updateBankLinked()
}

final class YodleeScreenInteractor: PresentableInteractor<YodleeScreenPresentable>, YodleeScreenInteractable {

    weak var router: YodleeScreenRouting?
    weak var listener: LinkBankListener?

    private let bankLinkageData: BankLinkageData
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let yodleeRequestProvider: YodleeRequestProvider
    private let yodleeMessageService: YodleeMessageService
    private let yodleeActivationService: YodleeActivateService
    private let contentReducer: YodleeScreenContentReducer

    init(
        presenter: YodleeScreenPresentable,
        bankLinkageData: BankLinkageData,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        yodleeRequestProvider: YodleeRequestProvider,
        yodleeMessageService: YodleeMessageService,
        yodleeActivationService: YodleeActivateService,
        contentReducer: YodleeScreenContentReducer
    ) {
        self.bankLinkageData = bankLinkageData
        self.analyticsRecorder = analyticsRecorder
        self.yodleeRequestProvider = yodleeRequestProvider
        self.yodleeMessageService = yodleeMessageService
        self.yodleeActivationService = yodleeActivationService
        self.contentReducer = contentReducer
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        // register the webkit message handler for events
        yodleeMessageService.startMonitorEvents()

        // Setup actions
        let pendingContent = Driver.just(
            YodleeScreen.Action.pending(content: contentReducer.webviewPendingContent())
        )

        let loadAction = Driver.deferred { [weak self] () -> Driver<URLRequest?> in
            guard let self else { return .empty() }
            return .just(yodleeRequestProvider.provideRequest(using: bankLinkageData))
        }
        .compactMap { $0 }
        .map(YodleeScreen.Action.load)

        // Success message from Yodlee
        let successMessage = yodleeMessageService.effect
            .filter(\.isSuccess)
            .compactMap(\.successData)

        // Success message from Yodlee
        let errorMessageAction = yodleeMessageService.effect
            .filter(\.isFailure)
            .map { [contentReducer] _ in
                YodleeScreen.Action.failure(content: contentReducer.webviewFailureContent())
            }
            .asDriverCatchError()

        let activationResult = successMessage
            .flatMap { [weak self] data -> Single<YodleeActivateService.State> in
                guard let self else { return .just(.timeout) }
                return yodleeActivationService
                    .startPolling(for: bankLinkageData.id, providerAccountId: data.providerAccountId, accountId: data.accountId)
            }
            .catchAndReturn(.inactive(.unknown))
            .share(replay: 1, scope: .whileConnected)

        activationResult
            .map(\.isActive)
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak listener] _ in
                listener?.updateBankLinked()
            }
            .disposeOnDeactivate(interactor: self)

        let activationContentAction = activationResult
            .distinctUntilChanged()
            .do(onNext: { [weak self] state in
                self?.recordAnalytics(for: state)
            })
            .map { [weak self] state -> YodleeScreen.Action in
                guard let self else { return .none }
                return state.toScreenAction(reducer: contentReducer)
            }
            .asDriverCatchError()

        // Handle effects for opening an external url and closure of webview
        yodleeMessageService.effect
            .filter { !$0.isSuccess }
            .map(transformEffect(from:))
            .asDriverCatchError()
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        let successPendingAction = successMessage
            .map { [weak self] _ -> YodleeScreen.Action in
                guard let self else { return .none }
                return .pending(
                    content: contentReducer.linkingBankPendingContent()
                )
            }
            .asDriverCatchError()

        contentReducer.continueButtonViewModel.tap
            .asObservable()
            .withLatestFrom(activationResult)
            .filter(\.isActive)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                self.listener?.closeFlow(isInteractive: false)
            })
            .disposeOnDeactivate(interactor: self)

        let retryContentFromTap = Signal.merge(
            contentReducer.tryAgainButtonViewModel.tap,
            contentReducer.tryDifferentBankButtonViewModel.tap
        )
        .map { [contentReducer] _ in
            YodleeScreen.Action.pending(content: contentReducer.webviewPendingContent())
        }
        .asDriver(onErrorJustReturn: .none)

        let retryLoadAction = retryContentFromTap
            .compactMap { [weak self] _ -> URLRequest? in
                guard let self else { return nil }
                return yodleeRequestProvider.provideRequest(using: bankLinkageData)
            }
            .map(YodleeScreen.Action.load)

        Signal.merge(
            contentReducer.cancelButtonViewModel.tap,
            contentReducer.okButtonViewModel.tap
        )
        .map { _ in YodleeScreen.Effect.closeFlow(false) }
        .emit(onNext: handle(effect:))
        .disposeOnDeactivate(interactor: self)

        // Presenter Connection
        let pendingActions = Driver.merge(
            pendingContent, retryContentFromTap, successPendingAction, errorMessageAction, activationContentAction
        )
        presenter.connect(action: Driver.merge(loadAction, retryLoadAction, pendingActions))
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handle(effect: YodleeScreen.Effect) {
        switch effect {
        case .link(let url):
            router?.route(to: .link(url: url))
        case .closeFlow(let isInteractive):
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAchClose)
            listener?.closeFlow(isInteractive: isInteractive)
        case .back:
            listener?.returnToSplashScreen()
        case .none:
            break
        }
    }

    private func transformEffect(from messageEffect: YodleeMessageService.Effect) -> YodleeScreen.Effect {
        switch messageEffect {
        case .openExternal(let url):
            return .link(url: url)
        case .success:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAchSuccess)
            return .none // will be handled as an action (successMessage)
        case .closed:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAchClose)
            listener?.closeFlow(isInteractive: false)
        case .error:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAchError)
            return .none // will be handled as an action (errorMessageAction)
        case .none:
            return .none
        }
        return .none
    }

    private func recordAnalytics(for state: YodleeActivateService.State) {
        switch state {
        case .active:
            analyticsRecorder.record(events: [
                AnalyticsEvents.SimpleBuy.sbBankLinkSuccess(partner: .ach)
            ])
        case .inactive(let error):
            guard let error else {
                return
            }
            recordAnalytics(for: error)
        case .timeout:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbBankLinkGenericError(partner: .ach))
        }
    }

    private func recordAnalytics(for error: LinkedBankData.LinkageError) {
        switch error {
        case .alreadyLinked:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAlreadyLinkedError(partner: .ach))
        case .infoNotFound:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbIncorrectAccountError(partner: .ach))
        case .nameMismatch:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbAccountMismatchedError(partner: .ach))
        default:
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbBankLinkGenericError(partner: .ach))
        }
    }
}
