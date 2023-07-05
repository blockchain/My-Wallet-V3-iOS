// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import DIKit
import FeatureDexData
import FeatureDexDomain
import SwiftUI

@MainActor
struct DexAllowanceView: View {

    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app
    @StateObject var model: Model

    init(cryptoCurrency: CryptoCurrency) {
        self.init(
            model: Model(
                cryptocurrency: cryptoCurrency,
                network: EnabledCurrenciesService.default.network(for: cryptoCurrency)
            )
        )
    }

    init(model: DexAllowanceView.Model) {
        _model = StateObject(wrappedValue: model)
    }

    @ViewBuilder
    var body: some View {
        switch model.output {
        case nil:
            loading
                .onAppear {
                    model.onAppear()
                }
        case .failure(let error):
            ErrorView(ux: error)
        case .success:
            VStack(spacing: 0) {
                Spacer(minLength: Spacing.padding6)
                header
                    .padding([.bottom, .top], Spacing.padding3)
                information
                    .padding(.bottom, Spacing.padding3)
                buttons
                    .padding(.bottom, Spacing.padding3)
                Spacer(minLength: Spacing.padding1)
            }
            .onChange(of: model.didFinish) { didFinish in
                if didFinish {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var loading: some View {
        ProgressView(value: 0.25)
            .progressViewStyle(BlockchainCircularProgressViewStyle())
            .frame(width: 20.vw, height: 20.vh)
            .padding()
    }

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 0) {
            model.cryptocurrency.logo(size: 88.pt)
                .padding(.bottom, Spacing.padding3)
            Text(headerTitle)
                .layoutPriority(1)
                .typography(.title3)
                .padding(.bottom, Spacing.padding1)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .foregroundColor(.semantic.title)
                .fixedSize(horizontal: false, vertical: true)
            Text(headerBody)
                .typography(.body1)
                .layoutPriority(1)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .foregroundColor(.semantic.text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Spacing.padding3)
    }

    private var headerTitle: String {
        String(format: L10n.Allowance.title, model.cryptocurrency.displayCode)
    }

    private var headerBody: String {
        String(format: L10n.Allowance.body, model.cryptocurrency.displayCode)
    }

    @ViewBuilder
    private var information: some View {
        VStack(spacing: Spacing.padding2) {
            feeInfo
            PrimaryDivider()
            walletInfo
        }
    }

    @ViewBuilder
    private var feeInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.textSpacing) {
            HStack(spacing: Spacing.padding1) {
                networkLogo
                Text("~\(feeCryptoValue?.displayString ?? "")")
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)
            }
            Text(L10n.Allowance.estimatedFee)
                .typography(.paragraph1)
                .foregroundColor(.semantic.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.padding2)
    }

    private var feeCryptoValue: CryptoValue? {
        guard
            let estimate = model.output?.success?.absoluteFeeEstimate,
            let currency = model.network?.nativeAsset
        else {
            return nil
        }
        return CryptoValue.create(minor: estimate, currency: currency)
    }

    @ViewBuilder
    private var walletInfo: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(L10n.Allowance.wallet)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                Text("Defi Wallet")
                    .typography(.body1)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(.semantic.body)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.textSpacing) {
                Text(L10n.Allowance.network)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
                HStack(spacing: Spacing.padding1) {
                    networkLogo
                    Text(model.network?.networkConfig.name ?? "")
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                }
            }
        }
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder
    private var networkLogo: some View {
        if let network = model.network {
            network.nativeAsset.logo(size: 16.pt)
        }
    }

    @ViewBuilder
    private var buttons: some View {
        HStack(spacing: Spacing.padding1) {
            MinimalButton(
                title: L10n.Allowance.decline,
                foregroundColor: .semantic.title,
                action: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            PrimaryButton(
                title: L10n.Allowance.approve,
                isLoading: model.didApprove,
                action: {
                    model.didApprove = true
                    model.approve(app: app)
                }
            )
            .disabled(model.didApprove)
        }
        .padding(.horizontal, Spacing.padding2)
    }
}

struct DexAllowanceView_Previews: PreviewProvider {

    typealias State = (
        String,
        Result<DelegatedCustodyTransactionOutput, UX.Error>?,
        Result<String, UX.Error>?
    )

    static var app: AppProtocol = App.preview.withPreviewData()

    static var states: [State] = [
        ("Loaded", .success(.preview), .success("0x")),
        ("Error", .failure(.mockUxError), nil),
        ("Loading", nil, nil)
    ]

    static var previews: some View {
        ForEach(states, id: \.0) { state in
            withDependencies {
                _ = app
                $0.transactionCreationService = TransactionCreationServicePreview(
                    buildAllowance: state.1,
                    signAndPush: state.2
                )
            } operation: {
                DexAllowanceView(cryptoCurrency: .ethereum)
                    .app(app)
                    .previewDisplayName(state.0)
            }
        }
    }
}
