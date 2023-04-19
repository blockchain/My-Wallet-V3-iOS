// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

public struct GraphView: View {

    typealias Localization = LocalizationConstants.Coin.Graph

    @BlockchainApp var app
    @Environment(\.context) var context

    let store: Store<GraphViewState, GraphViewAction>

    public init(store: Store<GraphViewState, GraphViewAction>) {
        self.store = store
    }

    @State private var animation = false

    func lineGraphColor(
        for start: GraphData.Index?,
        end: GraphData.Index?
    ) -> Color {
        guard let start, let end else {
            return Color.semantic.primary
        }
        return end.price.isRelativelyEqual(to: start.price)
                            ? Color.semantic.primary
                        : end.price < start.price ? .semantic.pink : Color.semantic.success
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.result {
                case .none:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear {
                            viewStore.send(.onAppear(context))
                        }
                        .padding([.leading, .trailing])
                    Spacer()
                case .failure:
                    Spacer()
                    Group {
                        AlertCard(
                            title: Localization.Error.title,
                            message: Localization.Error.description
                        )
                        SmallPrimaryButton(title: Localization.Error.retry, isLoading: viewStore.isFetching) {
                            viewStore.send(.request(viewStore.interval, force: true))
                        }
                    }
                    .padding()
                    Spacer()
                case .success(let value):
                    if value.series.isEmpty {
                        AlertCard(
                            title: Localization.Error.title,
                            message: Localization.Error.description
                        )
                    } else {
                        balance(
                            in: value,
                            series: viewStore.interval,
                            selected: viewStore.selected
                        )
                        LineGraph(
                            selection: viewStore.binding(\.$selected),
                            selectionTitle: { i, _ in
                                timestamp(value.series[i])
                            },
                            minimumTitle: { _, _ in
                                EmptyView()
                            },
                            maximumTitle: { _, _ in
                                EmptyView()
                            },
                            data: value.series.map(\.price),
                            tolerance: viewStore.tolerance,
                            density: viewStore.density
                        )
                        .lineGraphColor(
                            lineGraphColor(
                                for: value.series.first,
                                end: value.series.last
                            )
                        )
                        .opacity(viewStore.isFetching ? 0.5 : 1)
                        .overlay(
                            ZStack {
                                if animation {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                            }
                            .onChange(of: viewStore.isFetching) { isFetching in
                                guard isFetching else {
                                    animation = false
                                    return
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if viewStore.isFetching {
                                        animation = true
                                    }
                                }
                            }
                            .animation(.linear, value: animation)
                        )
                        .typography(.caption2)
                        .foregroundColor(.semantic.light)
                        .animation(.easeInOut)
                        .onChange(of: viewStore.selected) { [old = viewStore.selected] new in
                            #if canImport(UIKit)
                            switch (new, old) {
                            case (.some, .some):
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            case _:
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                            #endif
                            switch (old, new) {
                            case (.none, .some):
                                app.post(
                                    event: blockchain.ux.asset.chart.selected[].ref(to: context),
                                    context: [blockchain.ux.asset.chart.interval[]: viewStore.interval]
                                )
                            case (.some, .none):
                                app.post(
                                    event: blockchain.ux.asset.chart.deselected[].ref(to: context),
                                    context: [blockchain.ux.asset.chart.interval[]: viewStore.interval]
                                )
                            case _:
                                break
                            }
                        }
                    }
                }
                Spacer()
                PrimarySegmentedControl(
                    items: [
                        PrimarySegmentedControl.Item(title: "1D", identifier: .day),
                        PrimarySegmentedControl.Item(title: "1W", identifier: .week),
                        PrimarySegmentedControl.Item(title: "1M", identifier: .month),
                        PrimarySegmentedControl.Item(title: "1Y", identifier: .year),
                        PrimarySegmentedControl.Item(title: "ALL", identifier: .all)
                    ],
                    selection: Binding(
                        get: { viewStore.interval },
                        set: { newValue in viewStore.send(.request(newValue)) }
                    ),
                    backgroundColor: .WalletSemantic.light
                )
                .onChange(of: viewStore.interval) { interval in
                    app.post(
                        value: interval,
                        of: blockchain.ux.asset.chart.interval[].ref(to: context)
                    )
                }
                .disabled(viewStore.isFetching)
            }
        }
        .frame(maxWidth: 100.vw, minHeight: 48.vh)
    }

    private func timestamp(_ index: GraphData.Index) -> Text {
        Text("\(Self.dateFormatter.string(from: index.timestamp))")
    }

    private func amount(quote: FiatCurrency, _ index: Int, _ value: Double) -> some View {
        Text(amount: value, currency: quote)
            .padding(2.pt)
            .background(
                RoundedRectangle(cornerSize: .init(length: 4))
                    .fill(Color.semantic.background.opacity(0.75))
                    .shadow(color: .semantic.background, radius: 3)
            )
    }

    private func balance(
        in value: GraphData,
        series: Series,
        selected: Int?
    ) -> some View {

        func view(
            for start: GraphData.Index,
            relativeTo end: GraphData.Index
        ) -> ChartBalance {
            let percentage = Self.percentageFormatter.string(
                from: NSNumber(
                    value: abs(1 - (end.price / start.price))
                )
            )!
            return ChartBalance(
                title: selected == nil ? Localization.currentPrice : Localization.price,
                balance: String(
                    amount: end.price,
                    currency: value.quote
                ),
                changeArrow: end.price.isRelativelyEqual(to: start.price)
                    ? "→"
                    : end.price < start.price ? "↓" : "↑",
                changeAmount: String(
                    amount: abs(end.price - start.price),
                    currency: value.quote
                ),
                changePercentage: "(\(percentage))",
                changeColor: end.price.isRelativelyEqual(to: start.price)
                    ? .semantic.primary
                : end.price < start.price ? .semantic.pink : .semantic.success,
                changeTime: Self.relativeDateFormatter.localizedString(
                    for: (
                        selected.flatMap { selection in
                            value.series.indices.contains(selection)
                                ? value.series[selection]
                                : nil
                        } ?? value.series[0]
                    ).timestamp,
                    relativeTo: value.series.last!.timestamp
                )
            )
        }

        if let selected, value.series.indices.contains(selected) {
            return view(for: value.series[0], relativeTo: value.series[selected])
        } else {
            return view(for: value.series[0], relativeTo: value.series.last!)
        }
    }

    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .standalone
        formatter.unitsStyle = .full
        return formatter
    }()
}

extension BinaryFloatingPoint {

    func isRelativelyEqual(to other: Self, precision: Self = .init(0.001)) -> Bool {
        abs(1 - (self / other)) <= precision
    }
}

struct GraphViewPreviewProvider: PreviewProvider {
    static var previews: some View {
        GraphView(
            store: .init(
                initialState: .init(),
                reducer: graphViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
    }
}
