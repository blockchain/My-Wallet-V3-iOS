// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import Combine
import Errors
import FeatureCardPaymentDomain
import FeatureVGSData
import PlatformKit
import SwiftUI
import ToolKit
import VGSCollectSDK

public struct VGSEnvironment {
    let retrieveCardTokenId: () -> AnyPublisher<CardTokenIdResponse, Errors.NabuError>
    let waitForActivationOfCard: (_ cardId: String) -> AnyPublisher<CardPayload, NabuNetworkError>
    let fetchCardsAndPreferId: (_ preferCardId: String) -> AnyPublisher<EmptyValue, Error>
    let cardSuccessRateService: (_ binNumber: String) -> AnyPublisher<CardSuccessRateData, CardSuccessRateServiceError>
}

private typealias L10n = LocalizationConstants.CardDetailsScreen

struct VGSContentView: View {

    @BlockchainApp var app

    private let environment: VGSEnvironment
    private let dismissBlock: () -> Void
    private let completeBlock: (CardPayload) -> Void

    init(
        environment: VGSEnvironment,
        completeBlock: @escaping (CardPayload) -> Void,
        dismissBlock: @escaping () -> Void
    ) {
        self.environment = environment
        self.completeBlock = completeBlock
        self.dismissBlock = dismissBlock
    }

    var body: some View {
        NavigationView {
            AsyncContentView(
                source: Model(retrieveToken: environment.retrieveCardTokenId),
                loadingView: loadingView,
                errorView: { error in
                    ErrorView(ux: .init(nabu: error))
                },
                content: { model in
                    contentView(model)
                }
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(L10n.title)
                            .typography(.body2)
                            .foregroundColor(.semantic.title)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.semantic.background)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: EmptyView(),
                trailing: IconButton(
                    icon: Icon.closeCirclev2,
                    action: dismissBlock
                )
            )
        }
    }

    @ViewBuilder
    func contentView(_ model: CardTokenIdResponse) -> some View {
        let vgsCollector = provideVGSCollect(vaultId: model.vgsVaultId)
        VGSAddCardView(
            environment: environment,
            vgsCollect: vgsCollector,
            cardTokenId: model.cardTokenId,
            configBuilder: .init(vgsCollect: vgsCollector),
            completeBlock: completeBlock,
            dismissBlock: dismissBlock
        )
    }

    var loadingView: some View {
        ProgressView()
            .progressViewStyle(.blockchain)
            .frame(width: 15.vw, height: 15.vh)
    }
}

extension VGSContentView {

    class Model: LoadableObject {
        typealias Output = CardTokenIdResponse
        typealias Failure = NabuError
        typealias State = Extensions.LoadingState<CardTokenIdResponse, NabuError>

        @Published var state: State = .idle

        private let retrieveToken: () -> AnyPublisher<CardTokenIdResponse, NabuError>

        init(retrieveToken: @escaping () -> AnyPublisher<CardTokenIdResponse, NabuError>) {
            self.retrieveToken = retrieveToken
        }

        func load() {
            retrieveToken()
                .receive(on: DispatchQueue.main)
                .map { State.loaded($0) }
                .catch { error -> AnyPublisher<State, Never> in
                    .just(State.failed(error))
                }
                .eraseToAnyPublisher()
                .assign(to: &$state)
        }
    }
}

func provideVGSCollect(vaultId: String) -> VGSCollect {
    let environment = BuildFlag.isInternal ? VGSCollectSDK.Environment.sandbox : VGSCollectSDK.Environment.live
    return VGSCollect(
        id: vaultId,
        environment: environment
    )
}
