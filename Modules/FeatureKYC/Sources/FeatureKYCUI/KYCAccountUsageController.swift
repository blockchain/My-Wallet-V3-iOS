// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import Localization
import ToolKit
import UIComponentsKit
import UIKit

final class KYCAccountUsageController: KYCBaseViewController {

    private static var defaultContext = "TIER_TWO_VERIFICATION"

    private var isBlocking: Bool = true
    private var bag: Set<AnyCancellable> = []

    override class func make(with coordinator: KYCRouter) -> KYCBaseViewController {
        let controller = KYCAccountUsageController()
        controller.pageType = .accountUsageForm
        controller.router = coordinator
        return controller
    }

    let app: AppProtocol = DIKit.resolve()
    let analyticsRecorder: AnalyticsEventRecorderAPI = DIKit.resolve()
    let accountUsageService: KYCAccountUsageServiceAPI = DIKit.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light
        embedAccountUsageView()
        title = LocalizationConstants.NewKYC.Steps.AccountUsage.title
    }

    var publisher: AnyPublisher<FeatureFormDomain.Form, Nabu.Error> {
        app.publisher(for: blockchain.ux.kyc.extra.questions.form.data)
            .flatMap { [app] data -> AnyPublisher<FeatureFormDomain.Form, Nabu.Error> in
                switch data {
                case .value(let value, _):
                    guard let form = value as? Result<FeatureFormDomain.Form, Nabu.Error> else { fallthrough }
                    return form.publisher.eraseToAnyPublisher()
                default:
                    return app.publisher(for: blockchain.ux.kyc.extra.questions.form[My.defaultContext].data)
                        .flatMap { data -> AnyPublisher<FeatureFormDomain.Form, Nabu.Error> in
                            if let result = data.value as? Result<FeatureFormDomain.Form, Nabu.Error> {
                                return result.publisher.eraseToAnyPublisher()
                            } else {
                                return Fail(
                                    outputType: FeatureFormDomain.Form.self,
                                    failure: Nabu.Error(
                                        id: UUID().uuidString,
                                        code: .missingBody,
                                        type: .missingBody
                                    )
                                )
                                .eraseToAnyPublisher()
                            }
                        }
                        .eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func embedAccountUsageView() {
        let view = AccountUsageView(
            store: .init(
                initialState: AccountUsage.State.idle,
                reducer: AccountUsage.reducer,
                environment: AccountUsage.Environment(
                    onComplete: continueToNextStep,
                    dismiss: dismissWithAnimation,
                    loadForm: { [form = publisher] in form },
                    submitForm: accountUsageService.submitExtraKYCQuestions,
                    analyticsRecorder: analyticsRecorder
                )
            )
        )
        publisher
            .map(\.blocking)
            .replaceError(with: false)
            .assign(to: \.isBlocking, on: self)
            .store(in: &bag)
        embed(view)
    }

    private func continueToNextStep() {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    @objc private func dismissWithAnimation() {
        app.state.clear(blockchain.ux.kyc.extra.questions.form.id)
        router.stop()
    }

    override func onNavControllerRightBarButtonWillDismiss() {
        clearExtraQuestionsData()
    }

    override func onNavControllerRightBarButtonSkip() {
        clearExtraQuestionsData()
        continueToNextStep()
    }

    private func clearExtraQuestionsData() {
        app.state.clear(blockchain.ux.kyc.extra.questions.form.id)
    }

    // MARK: - UI Configuration

    override func navControllerCTAType() -> NavigationCTA {
        if isBlocking {
            return .dismiss
        } else {
            return .skip
        }
    }
}
