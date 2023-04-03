import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureCoinDomain
import Localization
import SwiftUI

public struct RecurringBuySummaryView: View {

    private typealias L10n = LocalizationConstants.RecurringBuy.Summary

    @BlockchainApp var app
    @State var isBottomSheetPresented: Bool = false
    @Environment(\.context) var context
    @Environment(\.presentationMode) private var presentationMode

    @Environment(\.cancelRecurringBuy) private var cancelRecurringBuy

    @State private var scrollOffset: CGPoint = .zero
    @StateObject private var model = Model()

    let buy: RecurringBuy

    public init(buy: RecurringBuy) {
        self.buy = buy
    }

    public var body: some View {
        PrimaryNavigationView {
            VStack(alignment: .center, spacing: .zero) {
                ScrollView {
                    DividedVStack(spacing: .zero) {
                        Group {
                            TableRow(
                                title: TableRowTitle(L10n.amount).foregroundColor(.semantic.text),
                                trailing: {
                                    TableRowTitle(buy.amount)
                                }
                            )
                            TableRow(
                                title: TableRowTitle(L10n.crypto).foregroundColor(.semantic.text),
                                trailing: {
                                    TableRowTitle(buy.asset)
                                }
                            )
                            TableRow(
                                title: TableRowTitle(L10n.paymentMethod).foregroundColor(.semantic.text),
                                trailing: {
                                    TableRowTitle(buy.paymentMethodType)
                                }
                            )
                            TableRow(
                                title: TableRowTitle(L10n.frequency).foregroundColor(.semantic.text),
                                trailing: {
                                    TableRowTitle(buy.recurringBuyFrequency)
                                }
                            )
                            TableRow(
                                title: TableRowTitle(L10n.nextBuy).foregroundColor(.semantic.text),
                                trailing: {
                                    TableRowTitle(buy.nextPaymentDate)
                                }
                            )
                        }
                        .tableRowBackground(Color.semantic.background)
                    }
                    .scrollOffset($scrollOffset)
                    .cornerRadius(Spacing.padding2)
                    .padding(.top, Spacing.padding2)
                }
                .padding(.horizontal, Spacing.padding2)
                VStack(spacing: 0) {
                    DestructiveMinimalButton(
                        title: L10n.remove,
                        variant: .white
                    ) {
                        isBottomSheetPresented = true
                    }
                }
                .padding(.horizontal, Spacing.padding2)
            }
            .alert(item: $model.failure) { item in
                Alert(
                    title: Text(item.title),
                    message: Text(item.message),
                    dismissButton: .default(Text(L10n.Removal.Failure.ok))
                )
            }
            .onAppear {
                model.prepare(
                    app,
                    buyId: buy.id,
                    cancelRecurringBuy: cancelRecurringBuy
                )
            }
            .superAppNavigationBar(
                title: {
                    Text(L10n.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: {
                    IconButton(icon: .closeCirclev3.small()) {
                        $app.post(
                            event: blockchain.ux.asset.recurring.buy.summary.entry.paragraph.button.icon.tap
                        )
                    }
                },
                titleForFallbackVersion: L10n.title,
                scrollOffset: $scrollOffset.y
            )
            .background(Color.semantic.light.ignoresSafeArea())
        }
        .bottomSheet(isPresented: $isBottomSheetPresented) {
            RecurringBuyDeletionConfirmationView()
                .environmentObject(model)
        }
        .task {
            for await _ in app.on(blockchain.ux.asset.recurring.buy.summary.cancel.was.successful).stream() {
                $app.post(
                    event: blockchain.ux.asset.recurring.buy.summary.entry.paragraph.button.minimal.tap
                )
            }
        }
        .batch {
            set(blockchain.ux.asset.recurring.buy.summary.entry.paragraph.button.icon.tap.then.close, to: true)
            set(blockchain.ux.asset.recurring.buy.summary.entry.paragraph.button.minimal.tap.then.close, to: true)
        }
    }
}

struct RecurringBuyDeletionConfirmationView: View {

    @BlockchainApp var app
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var model: RecurringBuySummaryView.Model

    private typealias L10n = LocalizationConstants.RecurringBuy.Summary.Removal

    var body: some View {
        VStack(spacing: Spacing.padding3) {
            VStack(spacing: 24) {
                ZStack(alignment: .topTrailing) {
                    Icon.delete
                        .circle()
                        .color(.semantic.primary)
                        .frame(width: 88, height: 88)
                    Circle()
                        .fill(.white)
                        .frame(width: 36.0, height: 36.0)
                        .overlay(
                            Icon.alert
                                .color(.semantic.warning)
                                .frame(width: 34.0, height: 24.0)
                        )
                        .offset(x: 8.0, y: -8.0)
                }
                Text(L10n.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding2)
            DestructiveMinimalButton(
                title: L10n.remove,
                isLoading: model.isCancelling,
                action: {
                    app.post(
                        event: blockchain.ux.asset.recurring.buy.summary.cancel.tapped
                    )
                }
            )
            .padding(.horizontal, Spacing.padding3)
        }
        .padding([.top, .bottom], Spacing.padding2)
    }
}

extension RecurringBuySummaryView {
    class Model: ObservableObject {

        struct FailureModel: Identifiable {
            var id: String {
                title + message
            }
            let title: String
            let message: String
        }

        private var bag = Set<AnyCancellable>()

        @Published var isCancelling: Bool = false
        @Published var failure: FailureModel?

        func prepare(
            _ app: AppProtocol,
            buyId: String,
            cancelRecurringBuy: CancelRecurringBuyEnvironment
        ) {
            app.on(blockchain.ux.asset.recurring.buy.summary.cancel.tapped)
                .flatMapLatest { [cancelRecurringBuy] _ -> AnyPublisher<Result<Void, NabuNetworkError>, Never> in
                    cancelRecurringBuy.processCancel(buyId)
                        .result()
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .sink { [app, weak self] result in
                    guard let self else { return }
                    self.isCancelling = false
                    switch result {
                    case .success:
                        app.post(event: blockchain.ux.asset.recurring.buy.summary.cancel.was.successful)
                    case .failure(let error):
                        self.failure = FailureModel(
                            title: L10n.Removal.Failure.title,
                            message: String(format: L10n.Removal.Failure.message, String(error.code.rawValue))
                        )
                    }
                }
                .store(in: &bag)

            app.on(blockchain.ux.asset.recurring.buy.summary.cancel.tapped)
                .map { _ in true }
                .assign(to: &$isCancelling)
        }
    }
}

// MARK: - Dependencies

extension RecurringBuySummaryView {
    public func provideCancelRecurringBuyService(_ service: CancelRecurringBuyEnvironment) -> some View {
        environment(\.cancelRecurringBuy, service)
    }
}

public struct CancelRecurringBuyEnvironment {
    public var processCancel: (_ id: String) -> AnyPublisher<Void, NabuNetworkError>

    public init(processCancel: @escaping (_ id: String) -> AnyPublisher<Void, NabuNetworkError>) {
        self.processCancel = processCancel
    }
}

struct CancelRecurringBuyKey: EnvironmentKey {
    static var defaultValue: CancelRecurringBuyEnvironment = CancelRecurringBuyEnvironment(
        processCancel: { _ in
            fatalError("Requires to pass implementation")
        }
    )
}

extension EnvironmentValues {
    var cancelRecurringBuy: CancelRecurringBuyEnvironment {
        get { self[CancelRecurringBuyKey.self] }
        set { self[CancelRecurringBuyKey.self] = newValue }
    }
}

// MARK: - Preview

struct RecurringBuySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuySummaryView(
            buy: .init(
                id: "123",
                recurringBuyFrequency: "Once a Week",
                nextPaymentDate: "Next Monday",
                paymentMethodType: "Cash Wallet",
                amount: "$20.00",
                asset: "Bitcoin"
            )
        )
    }
}
