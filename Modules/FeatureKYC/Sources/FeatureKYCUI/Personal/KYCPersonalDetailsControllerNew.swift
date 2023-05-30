// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import DIKit
import FeatureFormDomain
import FeatureKYCDomain
import PlatformKit
import SwiftUI
import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsControllerNew: KYCBaseViewController {

    // MARK: Public Properties

    var personalDetailsService = PersonalDetailsService()
    var analyticsRecorder: AnalyticsEventRecorderAPI = resolve()

    // MARK: Private Properties

    @Published private var user: User?

    // MARK: Overrides

    override class func make(with coordinator: KYCRouter) -> KYCPersonalDetailsControllerNew {
        let controller = KYCPersonalDetailsControllerNew()
        controller.router = coordinator
        controller.pageType = .profile
        return controller
    }

    override func apply(model: KYCPageModel) {
        guard user == nil else { return }
        guard case .personalDetails(let user) = model else { return }
        self.user = user
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.semantic.light
        embedContentView()
    }

    // MARK: Helpers

    private func embedContentView() {
        let view = PersonalInfoView(
            store: Store(
                initialState: PersonalInfo.State(),
                reducer: PersonalInfo.reducer,
                environment: PersonalInfo.Environment(
                    onClose: dismiss,
                    onComplete: moveToNextStep,
                    loadForm: loadForm,
                    submitForm: onSubmission,
                    analyticsRecorder: analyticsRecorder,
                    mainQueue: .main
                )
            )
        )
        .background(Color.semantic.light.ignoresSafeArea())
        embed(view)
    }

    private func loadForm() -> AnyPublisher<[FormQuestion], KYCFlowError> {
        $user.map {
            FormQuestion.personalInfoQuestions(
                firstName: $0?.personalDetails.firstName,
                lastName: $0?.personalDetails.lastName,
                dateOfBirth: $0?.personalDetails.birthday
            )
        }
        .setFailureType(to: KYCFlowError.self)
        .eraseToAnyPublisher()
    }

    private func onSubmission(_ form: [FormQuestion]) -> AnyPublisher<Void, KYCFlowError> {
        guard
            let firstName: String = try? form.answer(id: PersonalInfo.InputField.firstName.rawValue),
            let lastName: String = try? form.answer(id: PersonalInfo.InputField.lastName.rawValue),
            let birthday: Date = try? form.answer(id: PersonalInfo.InputField.dateOfBirth.rawValue)
        else {
            return .failure(KYCFlowError.invalidForm)
        }
        return personalDetailsService
            .update(firstName: firstName, lastName: lastName, birthday: birthday)
            .mapError(KYCFlowError.networkError)
            .eraseToAnyPublisher()
    }

    private func moveToNextStep() {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    private func dismiss() {
        router.stop()
    }
}
