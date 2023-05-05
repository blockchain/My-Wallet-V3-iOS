// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Localization
import MoneyKit
import SwiftUI

@MainActor
public struct DexSettingsView: View {

    private typealias L10n = LocalizationConstants.Dex.Settings

    struct Model: Identifiable, Hashable {
        var id: String { label }

        let value: Double
        let label: String

        init(value: Double) {
            self.value = value
            self.label = percentageFormatter
                .string(from: NSNumber(value: value)) ?? "\(value * 100)%"
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
            Text(L10n.body)
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
            Text(L10n.title)
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
private let percentageFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 1
    formatter.minimumFractionDigits = 1
    return formatter
}()

@available(iOS 15, *)
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
