// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import MoneyKit
import SwiftUI

@MainActor
public struct DexSettingsView: View {

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

    public init(slippage: Double) {
        self.init(selected: Model(value: slippage))
    }

    init(selected: Model) {
        _selected = State(initialValue: selected)
    }

    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.top, Spacing.padding2)
                .padding(.bottom, Spacing.padding3)
            picker
                .padding(.bottom, Spacing.padding2)
            Text(L10n.Settings.body)
                .typography(.paragraph1)
                .foregroundColor(.semantic.body)
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.background.ignoresSafeArea())
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
        HStack(spacing: 0) {
            Text(L10n.Settings.title)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            Spacer()
            Icon.closeCirclev2
                .frame(width: 24, height: 24)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}

private let allowedSlippages: [Double] = [0.002, 0.005, 0.01, 0.03]
let defaultSlippage: Double = 0.005
func formatSlippage(_ value: Double) -> String {
    if #available(iOS 15, *) {
        return value.formatted(.percent)
    } else {
        fatalError("<iOS15 not supported")
    }
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
