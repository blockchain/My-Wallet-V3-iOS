import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import Dependencies
import DIKit
import Errors
import FeatureCoinDomain
import FeatureCoinUI
import FeatureTransactionDomain
import Localization
import MoneyKit
import SwiftUI

public struct RecurringBuyManageView: View {

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler

    private typealias L10n = LocalizationConstants.RecurringBuy.Manage

    @State private var scrollOffset: CGPoint = .zero
    @StateObject private var model = Model()

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                DividedVStack(spacing: 0) {
                    ForEach(model.buys) { item in
                        TableRow(
                            leading: {
                                iconView(item.asset)
                            },
                            title: {
                                Text("\(item.amount) \(item.recurringBuyFrequency)")
                                    .typography(.body2)
                                    .foregroundColor(.semantic.title)
                            },
                            byline: {
                                Group {
                                    Text(L10n.nextBuy) +
                                    Text(item.nextPaymentDate)
                                }
                                .typography(.caption1)
                                .foregroundColor(.semantic.body)
                            }
                        )
                        .tableRowChevron(true)
                        .tableRowBackground(Color.semantic.background)
                        .cornerRadius(
                            Spacing.padding1,
                            corners: rowCorners(
                                isFirstItem: model.buys.first?.id == item.id,
                                isLastItem: model.buys.last?.id == item.id
                            )
                        )
                        .batch {
                            set(
                                blockchain.ux.asset[item.asset].recurring.buy.summary[item.id].entry.paragraph.row.tap.then.enter.into,
                                to: blockchain.ux.asset[item.asset].recurring.buy.summary[item.id]
                            )
                        }
                        .onTapGesture {
                            app.post(
                                event: blockchain.ux.asset[item.asset].recurring.buy.summary[item.id].entry.paragraph.row.tap,
                                context: [
                                    blockchain.ux.asset[item.asset].recurring.buy.summary[item.id].model: item,
                                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                                ]
                            )
                        }
                    }
                }
                .scrollOffset($scrollOffset)
                .padding(.top, Spacing.padding2)
                .padding(.horizontal, Spacing.padding2)
            }
            Spacer()
            VStack(spacing: 0) {
                PrimaryButton(
                    title: L10n.buttonTitle
                ) {
                    app.post(event: blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.icon.tap)
                    app.post(event: blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.primary.tap)
                }
            }
            .padding(.horizontal, Spacing.padding2)
        }
        .onAppear {
            model.prepare(app)
        }
        .superAppNavigationBar(
            title: {
                Text(L10n.title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                IconButton(icon: .closeCirclev3.small()) {
                    app.post(
                        event: blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.icon.tap
                    )
                }
            },
            titleForFallbackVersion: L10n.title,
            scrollOffset: $scrollOffset.y
        )
        .batch {
            set(blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.primary.tap.then.enter.into, to: blockchain.ux.transaction["buy"].select.target)
            set(blockchain.ux.dashboard.recurring.buy.manage.entry.paragraph.button.icon.tap.then.close, to: true)
        }
        .background(Color.semantic.light.ignoresSafeArea())
    }

    @ViewBuilder
    func iconView(_ asset: String) -> some View {
        if #available(iOS 15.0, *) {
            if let currency = CryptoCurrency(code: asset) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(url: currency.assetModel.logoPngUrl, placeholder: { EmptyView() })
                        .frame(width: 24.pt, height: 24.pt)
                        .background(currency.color, in: Circle())
                }
            }
        } else {
            EmptyView()
        }
    }

    private func rowCorners(
        isFirstItem: Bool,
        isLastItem: Bool
    ) -> UIRectCorner {
        if isFirstItem, isLastItem {
            return .allCorners
        } else if isFirstItem {
            return [.topLeft, .topRight]
        } else if isLastItem {
            return [.bottomLeft, .bottomRight]
        }
        return []
    }
}

extension RecurringBuyManageView {
    class Model: ObservableObject {
        @Dependency(\.recurringBuyService) var service

        typealias BuyItem = FeatureCoinDomain.RecurringBuy

        @Published var buys: [BuyItem] = []

        func prepare(_ app: AppProtocol) {

            app.on(blockchain.ux.asset.recurring.buy.summary.cancel.was.successful)
                .mapToVoid()
                .prepend(())
                .flatMap { [service] _ -> AnyPublisher<[FeatureTransactionDomain.RecurringBuy], NabuNetworkError> in
                    service.fetchRecurringBuys()
                        .eraseToAnyPublisher()
                }
                .map { (buys: [FeatureTransactionDomain.RecurringBuy]) in buys.map(BuyItem.init) }
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .assign(to: &$buys)
        }
    }
}

// MARK: - Dependencies

extension DependencyValues {
    var recurringBuyService: RecurringBuyEnvironment {
        get { self[RecurringBuyServiceKey.self] }
        set { self[RecurringBuyServiceKey.self] = newValue }
    }
}

public struct RecurringBuyEnvironment {
    public var fetchRecurringBuys: () -> AnyPublisher<[FeatureTransactionDomain.RecurringBuy], NabuNetworkError>

    public init(fetchRecurringBuys: @escaping () -> AnyPublisher<[FeatureTransactionDomain.RecurringBuy], NabuNetworkError>) {
        self.fetchRecurringBuys = fetchRecurringBuys
    }
}

private struct RecurringBuyServiceKey: DependencyKey {
    static var liveValue: RecurringBuyEnvironment {
        let service: RecurringBuyProviderRepositoryAPI = resolve()
        return RecurringBuyEnvironment(
            fetchRecurringBuys: service.fetchRecurringBuys
        )
    }
}
