import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import Localization
import MoneyKit
import PlatformKit
import SwiftUI
import UIComponentsKit

private typealias LocalizedIds = LocalizationConstants.Transaction.AvailableBalance

// MARK: State

public struct AvailableBalanceDetailViewState: Equatable {
    var title: String?
    var data: [Data]

    struct Data: Equatable, Hashable, Identifiable {
        let title: String
        let content: Content

        enum Content: Equatable, Hashable {
            case text(String)
            case badge(String)

            var displayString: String {
                switch self {
                case .text(let value):
                    return value
                case .badge(let value):
                    return value
                }
            }

            static func == (lhs: Content, rhs: Content) -> Bool {
                switch (lhs, rhs) {
                case (.text(let left), .text(let right)):
                    return left == right
                case (.badge(let left), .badge(let right)):
                    return left == right
                default:
                    return false
                }
            }
        }

        var id: String { "\(title).\(content)" }
    }

    init(
        title: String? = nil,
        data: [Data] = []
    ) {
        self.title = title
        self.data = data
    }
}

// MARK: - Reducer

public let availableBalanceDetailViewReducer = Reducer<
    AvailableBalanceDetailViewState,
    AvailableBalanceDetailViewAction,
    AvailableBalanceDetailViewEnvironment
> { state, action, environment in
    switch action {
    case .onAppear:

        let balancePublishers = Publishers.Zip(
            environment.balancePublisher,
            environment.availableBalancePublisher
        )

        let feesPublishers = Publishers.Zip(
            environment.feesPublisher,
            environment.transactionIsFeeLessPublisher
        )

        return Publishers.Zip3(
            balancePublishers,
            feesPublishers,
            environment.app
                .publisher(for: blockchain.ux.transaction.id, as: String.self)
                .compactMap(\.value)
                .compactMap { AssetAction(rawValue: $0) }
        )
            .map { payload -> (FiatValue, FiatValue, FiatValue, AssetAction, Bool) in
                let (balance, availableBalance) = payload.0
                let (fees, isTxFeeLess) = payload.1
                let assetAction = payload.2
                return (balance, availableBalance, fees, assetAction, isTxFeeLess)
            }
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(AvailableBalanceDetailViewAction.updateAvailableBalanceDetails)

    case .updateAvailableBalanceDetails(let balance, let available, let fees, let action, let isTxFeeLess):
        state.title = "\(LocalizedIds.availableTo) \(action.name)"
        state.data = [
            .init(title: LocalizedIds.total, content: .text(balance.displayString)),
            .init(title: "\(LocalizedIds.estimated) \(LocalizedIds.fees.lowercased())", content: isTxFeeLess ? .badge("Free") : .text(fees.displayString)),
            .init(title: "\(LocalizedIds.availableTo) \(action.name)", content: .text(available.displayString))
        ]
        return .none
    case .okayButtonTapped,
            .closeButtonTapped:
        return .fireAndForget {
            environment.closeAction?()
        }
    }
}

// MARK: - Environment

public struct AvailableBalanceDetailViewEnvironment {
    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let balancePublisher: AnyPublisher<FiatValue, Never>
    let availableBalancePublisher: AnyPublisher<FiatValue, Never>
    let feesPublisher: AnyPublisher<FiatValue, Never>
    let transactionIsFeeLessPublisher: AnyPublisher<Bool, Never>
    let closeAction: (() -> Void)?

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        balancePublisher: AnyPublisher<FiatValue, Never>,
        availableBalancePublisher: AnyPublisher<FiatValue, Never>,
        feesPublisher: AnyPublisher<FiatValue, Never>,
        transactionIsFeeLessPublisher: AnyPublisher<Bool, Never>,
        closeAction: (() -> Void)? = nil
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.balancePublisher = balancePublisher
        self.availableBalancePublisher = availableBalancePublisher
        self.feesPublisher = feesPublisher
        self.transactionIsFeeLessPublisher = transactionIsFeeLessPublisher
        self.closeAction = closeAction
    }

    static var preview: Self {
        AvailableBalanceDetailViewEnvironment(
            app: App.preview,
            balancePublisher: .empty(),
            availableBalancePublisher: .empty(),
            feesPublisher: .empty(),
            transactionIsFeeLessPublisher: .empty()
        )
    }
}

// MARK: - Actions

public enum AvailableBalanceDetailViewAction: Equatable {
    case onAppear
    case okayButtonTapped
    case updateAvailableBalanceDetails(_ balance: FiatValue, _ available: FiatValue, _ fees: FiatValue, _ action: AssetAction, _ isTxFeeLess: Bool)
    case closeButtonTapped
}

// MARK: View

struct AvailableBalanceDetailView: View {

    let store: Store<AvailableBalanceDetailViewState, AvailableBalanceDetailViewAction>

    init(store: Store<AvailableBalanceDetailViewState, AvailableBalanceDetailViewAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                closeHandle
                    .onTapGesture {
                        viewStore.send(.closeButtonTapped)
                    }
                HStack {
                    if let title = viewStore.title {
                        Text(title)
                            .typography(.title3)
                        Spacer()
                    }
                    IconButton(icon: .closev2.circle()) {
                        viewStore.send(.closeButtonTapped)
                    }
                    .frame(width: 24, height: 24)
                }
                .padding([.leading, .trailing], 24.pt)
                .padding([.bottom, .top], 16.pt)

                Text(LocalizedIds.description)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)

                ForEach(viewStore.data.indexed(), id: \.element) { index, data in
                    if index != viewStore.data.startIndex {
                        PrimaryDivider()
                    }
                    HStack {
                        Text(data.title)
                            .typography(.body1)
                        Spacer()
                        if case .text(let value) = data.content {
                            Text(value)
                                .typography(.body1)
                                .multilineTextAlignment(.trailing)
                        }
                        if case .badge(let value) = data.content {
                            BadgeView(title: value, style: .success)
                        }
                    }
                    .padding([.leading, .trailing], 24.pt)
                    .padding([.top, .bottom], 16.pt)
                }
                PrimaryButton(title: LocalizedIds.okay) {
                    viewStore.send(.okayButtonTapped)
                }
                .padding([.top, .bottom], 16.pt)
                .padding([.leading, .trailing], 24.pt)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    private var closeHandle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.semantic.medium)
            .frame(width: 32, height: 4)
            .padding(.top, Spacing.padding1)
            .padding(.bottom, 4.pt)
    }
}

struct AvailableBalanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableBalanceDetailView(
            store: .init(
                initialState: .init(data: []),
                reducer: availableBalanceDetailViewReducer,
                environment: .preview
            )
        )
    }
}
