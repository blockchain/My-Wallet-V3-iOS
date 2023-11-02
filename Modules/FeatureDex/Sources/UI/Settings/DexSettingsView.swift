// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftUI

@MainActor
struct DexSettingsView: View {

    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app
    @State var model: Model

    init(
        slippage: Double,
        expressMode: Bool,
        gasOnDestination: Bool
    ) {
        let model = Model(
            selected: Model.Slippage(value: slippage),
            expressMode: expressMode,
            gasOnDestination: gasOnDestination
        )
        self.init(model: model)
    }

    init(model: Model) {
        _model = .init(initialValue: model)
    }

    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    slippageView
                    if model.expressModeAllowed || model.gasOnDestinationAllowed {
                        extraSettings
                    }
                }
            }
        }
        .bindings {
            subscribe(
                $model.expressModeAllowed,
                to: blockchain.ux.currency.exchange.dex.config.cross.chain.settings.express.is.enabled
            )
        }
        .bindings {
            subscribe(
                $model.gasOnDestinationAllowed,
                to: blockchain.ux.currency.exchange.dex.config.cross.chain.settings.destination.gas.is.enabled
            )
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.light)
        .superAppNavigationBar(
            leading: { EmptyView() },
            title: {
                Text(L10n.Settings.title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                IconButton(icon: .navigationCloseButton()) {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(width: 20, height: 20)
            },
            scrollOffset: nil
        )
    }

    @ViewBuilder
    private var extraSettings: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            Text(L10n.Settings.crossChainTitle)
                .typography(.body2)
                .foregroundColor(.semantic.body)
                .lineSpacing(4)
            DividedVStack(spacing: 0) {
                expressModeRow
                gasOnDestinationRow
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.background)
            )
        }
    }

    @ViewBuilder
    private var expressModeRow: some View {
        if model.expressModeAllowed {
            tableRow(
                icon: .flashOn,
                title: L10n.Settings.Express.title,
                body: L10n.Settings.Express.body,
                isOn: $model.expressMode
            )
            .onChange(of: model.expressMode) { newValue in
                $app.post(
                    value: newValue,
                    of: blockchain.ux.currency.exchange.dex.settings.express.mode
                )
            }
        }
    }

    @ViewBuilder
    private var gasOnDestinationRow: some View {
        if model.gasOnDestinationAllowed {
            tableRow(
                icon: .gas,
                title: L10n.Settings.DestinationGas.title,
                body: L10n.Settings.DestinationGas.body,
                isOn: $model.gasOnDestination
            )
            .onChange(of: model.gasOnDestination) { newValue in
                $app.post(
                    value: newValue,
                    of: blockchain.ux.currency.exchange.dex.settings.gas.on.destination
                )
            }
        }
    }

    @ViewBuilder
    private func tableRow(
        icon: Icon,
        title: String,
        body: String,
        isOn: Binding<Bool>
    ) -> some View {
        TableRow(
            leading: { icon.color(.semantic.title).small() },
            title: { TableRowTitle(title) },
            byline: { TableRowByline(body) },
            isOn: isOn
        )
    }

    @ViewBuilder
    private var slippageView: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            Text(L10n.Settings.Slippage.title)
                .typography(.body2)
                .foregroundColor(.semantic.body)
                .lineSpacing(4)
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                picker
                Text(L10n.Settings.Slippage.body)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
                    .lineSpacing(Spacing.textSpacing)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.padding2)
                    .fill(Color.semantic.background)
            )
        }
    }

    @ViewBuilder
    private var picker: some View {
        HStack(spacing: Spacing.padding1) {
            Spacer()
            ForEach(model.slippageModels) { item in
                if item == model.selected {
                    SmallSecondaryButton(
                        title: item.label,
                        action: { select(item) }
                    )
                } else {
                    SmallMinimalButton(
                        title: item.label,
                        action: { select(item) }
                    )
                }
            }
            Spacer()
        }
    }

    private func select(_ item: Model.Slippage) {
        model.selected = item
        $app.post(value: item.value, of: blockchain.ux.currency.exchange.dex.settings.slippage)
    }
}

struct DexSettingsView_Previews: PreviewProvider {

    static let app: AppProtocol = App.preview.withPreviewData()

    static var previews: some View {
        VStack {
            Spacer()
            DexSettingsView(
                slippage: defaultSlippage,
                expressMode: true,
                gasOnDestination: true
            )
            .app(app)
            Spacer()
        }
    }
}
