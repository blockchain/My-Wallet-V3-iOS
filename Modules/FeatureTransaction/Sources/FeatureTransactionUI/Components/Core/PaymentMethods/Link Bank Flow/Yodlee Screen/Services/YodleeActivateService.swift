// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxSwift

final class YodleeActivateService {

    enum State: Equatable {
        case active(LinkedBankData)
        case inactive(LinkedBankData.LinkageError?)
        case timeout

        var isActive: Bool {
            switch self {
            case .active:
                true
            default:
                false
            }
        }

        var data: LinkedBankData? {
            switch self {
            case .active(let data):
                data
            default:
                nil
            }
        }
    }

    private let activationService: LinkedBankActivationServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI

    init(
        activationService: LinkedBankActivationServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve()
    ) {
        self.activationService = activationService
        self.paymentMethodTypesService = paymentMethodTypesService
    }

    func startPolling(for bankId: String, providerAccountId: String, accountId: String) -> Single<State> {
        activationService
            .waitForActivation(of: bankId, paymentAccountId: providerAccountId, accountId: accountId)
            .flatMap(weak: self) { (self, result) -> Single<State> in
                switch result {
                case .final(let state):
                    switch state {
                    case .active(let data):
                        if let error = data.error {
                            return .just(.inactive(error))
                        }
                        return self.paymentMethodTypesService
                            .fetchLinkBanks(andPrefer: bankId)
                            .andThen(Single.just(.active(data)))
                    case .pending:
                        return .just(.inactive(nil))
                    case .inactive(let data):
                        guard let data else {
                            return .just(.inactive(nil))
                        }
                        return .just(.inactive(data.error))
                    }
                case .cancel:
                    return .just(.inactive(nil))
                case .timeout:
                    return .just(.timeout)
                }
            }
    }
}

extension YodleeActivateService.State {
    func toScreenAction(reducer: YodleeScreenContentReducer) -> YodleeScreen.Action {
        switch self {
        case .active(let data):
            return .success(
                content: reducer.webviewSuccessContent(bankName: data.account?.bankName)
            )
        case .inactive(let error):
            guard let error else {
                return .pending(
                    content: reducer.webviewPendingContent()
                )
            }
            return .failure(
                content: reducer.linkingBankFailureContent(error: error)
            )
        case .timeout:
            return .failure(
                content: reducer.linkingBankFailureContent(error: .failed)
            )
        }
    }
}
