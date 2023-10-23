// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftUI

@MainActor
struct DexSettingsView: View {

    struct Model: Identifiable, Hashable {
        var id: String { label }

        let value: Double
        let label: String

        init(value: Double) {
            self.value = value
            self.label = formatSlippage(value)
        }
    }

    private let models: [Model] = allowedSlippages.map(Model.init(value:))
    @State private var selected: Model
    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app

    init(slippage: Double) {
        self.init(selected: Model(value: slippage))
    }

    init(selected: Model) {
        _selected = State(initialValue: selected)
    }

    @ViewBuilder
    var body: some View {
        VStack(spacing: 16) {
            header
            slippageView
            // Not yet enabled:
            // extraSettings
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.light)
    }

    @ViewBuilder
    private var extraSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cross-chain only")
                .typography(.body2)
                .foregroundColor(.semantic.body)
                .lineSpacing(4)

            DividedVStack {
                tableRow(
                    icon: .flashOn,
                    title: "Express",
                    body: "Reduces cross-chain transaction time to 5-30s (max $20k).",
                    isOn: .constant(true)
                )
                tableRow(
                    icon: .flashOn,
                    title: "Arrival gas",
                    body: "Swap some of your tokens for gas on destination chain.",
                    isOn: .constant(true)
                )
            }
            .padding(.vertical, 6.pt)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.background)
            )
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
            Text("Allowed slippage")
                .typography(.body2)
                .foregroundColor(.semantic.body)
                .lineSpacing(4)
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                picker
                Text(L10n.Settings.body)
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
            ForEach(models) { model in
                if model == selected {
                    SmallSecondaryButton(
                        title: model.label,
                        action: { select(model) }
                    )
                } else {
                    SmallMinimalButton(
                        title: model.label,
                        action: { select(model) }
                    )
                }
            }
            Spacer()
        }
    }

    private func select(_ model: Model) {
        selected = model
        app.post(value: model.value, of: blockchain.ux.currency.exchange.dex.settings.slippage)
    }

    @ViewBuilder
    private var header: some View {
        ZStack {
            Text(L10n.Settings.title)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            HStack {
                Spacer()
                IconButton(icon: .navigationCloseButton()) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

private let allowedSlippages: [Double] = [0.002, 0.005, 0.01, 0.03]
let defaultSlippage: Double = 0.005
func formatSlippage(_ value: Double) -> String {
    value.formatted(.percent)
}

struct DexSettingsView_Previews: PreviewProvider {

    static let app: AppProtocol = App.preview.withPreviewData()

    static var previews: some View {
        VStack {
            Spacer()
            DexSettingsView(slippage: defaultSlippage)
                .app(app)
            Spacer()
        }
    }
}
