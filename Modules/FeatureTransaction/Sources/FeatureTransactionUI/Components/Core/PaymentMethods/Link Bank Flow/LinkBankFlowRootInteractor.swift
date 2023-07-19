// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

enum LinkBankFlow {
    enum FailureReason: Error {
        case generic
    }

    enum Screen {
        case splash(data: BankLinkageData)
        case yodlee(data: BankLinkageData)
        case yapily(data: BankLinkageData)
        case failure(FailureReason)
    }

    enum Action: Equatable {
        case load
        case retry
    }
}

protocol LinkBankFlowRootRouting: Routing {
    func route(to screen: LinkBankFlow.Screen)
    func closeFailureScreen()
    func closeFlow(isInteractive: Bool)
    func returnToSplashScreen()
}

final class LinkBankFlowRootInteractor: Interactor,
    LinkBankFlowRootInteractable
{

    // MARK: - Properties

    let linkBankFlowEffect: Observable<LinkBankFlowEffect>
    weak var router: LinkBankFlowRootRouting?

    // MARK: - Private Properties

    private let bankFlowEffectRelay = PublishRelay<LinkBankFlowEffect>()
    internal let retryAction = PublishRelay<LinkBankFlow.Action>()

    // MARK: - Injected

    private let app: AppProtocol
    private let linkedBankService: LinkedBanksServiceAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let beneficiariesService: BeneficiariesServiceAPI

    private var bag: Set<AnyCancellable> = []

    init(
        app: AppProtocol = resolve(),
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        beneficiariesService: BeneficiariesServiceAPI = resolve()
    ) {
        self.app = app
        self.linkedBankService = linkedBankService
        self.loadingViewPresenter = loadingViewPresenter
        self.beneficiariesService = beneficiariesService
        self.linkBankFlowEffect = bankFlowEffectRelay
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let loadAction = Observable<LinkBankFlow.Action>.just(.load)
        let retryAction = retryAction
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        Observable.merge(loadAction, retryAction)
            .flatMapLatest { [linkedBankService, loadingViewPresenter] _ -> Single<Result<BankLinkageData?, BankLinkageError>> in
                linkedBankService.bankLinkageStartup
                    .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
                    .catchAndReturn(.failure(.generic))
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: handleInitialRouting)
            .disposeOnDeactivate(interactor: self)

        // Refresh the underlying value of BeneficiariesService once we've linked a bank
        linkBankFlowEffect
            .filter { $0 == .bankLinked }
            .flatMap { [beneficiariesService] _ -> Single<LinkBankFlowEffect> in
                beneficiariesService.fetch()
                    .take(1)
                    .asSingle()
                    .map { _ in LinkBankFlowEffect.bankLinked }
            }
            .subscribe()
            .disposeOnDeactivate(interactor: self)

        retryAction
            .subscribe(onNext: { [weak router] _ in
                router?.closeFailureScreen()
            })
            .disposeOnDeactivate(interactor: self)
    }

    func route(to screen: LinkBankFlow.Screen) {
        router?.route(to: screen)
    }

    func closeFlow(isInteractive: Bool) {
        bankFlowEffectRelay.accept(.closeFlow(isInteractive))
    }

    func returnToSplashScreen() {
        router?.returnToSplashScreen()
    }

    func updateBankLinked() {
        bankFlowEffectRelay.accept(.bankLinked)
        linkedBankService.invalidate()
        beneficiariesService.invalidate()
    }

    // MARK: - Private

    private func handleInitialRouting(with result: Result<BankLinkageData?, BankLinkageError>) {
        switch result {
        case .success(let data):
            guard let data else {
                router?.route(to: .failure(.generic))
                return
            }
            switch data.partner {
            case .yapily:
                app.publisher(for: blockchain.ux.payment.method.open.banking.is.enabled, as: Bool.self).replaceError(with: true)
                    .if(
                        then: { [weak self] in self?.route(to: .yapily(data: data)) },
                        else: { [weak self] in self?.route(to: .failure(.generic)) }
                    )
                    .store(in: &bag)
            case .yodlee:
                route(to: .splash(data: data))
            }
        case .failure:
            route(to: .failure(.generic))
        }
    }
}
