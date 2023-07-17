// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureTransactionDomain
import Localization
import PlatformUIKit
import RxSwift
import SwiftUI

public struct SellEnterAmountView: View {
    @BlockchainApp var app
    let store: StoreOf<SellEnterAmount>
    @ObservedObject var viewStore: ViewStore<SellEnterAmount.State, SellEnterAmount.Action>

    public init(store: StoreOf<SellEnterAmount>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.semantic.light
                VStack {
                    Spacer()
                    valuesContainer(viewStore)
                    Spacer()
                    PrefillButtonsView(store:
                                        store.scope(
                                            state: \.prefillButtonsState,
                                            action: SellEnterAmount.Action.prefillButtonAction
                                        )
                    )
                    .frame(width: 375, height: 60)

                    ZStack(alignment: .center) {
                        HStack(spacing: Spacing.padding1, content: {
                            fromView
                                .cornerRadius(16, corners: .allCorners)
                            targetView
                                .cornerRadius(16, corners: .allCorners)
                        })
                        .padding(.horizontal, Spacing.padding2)

                        Icon
                            .arrowRight
                            .color(.semantic.title)
                            .small()
                            .padding(2)
                            .background(Color.semantic.background)
                            .clipShape(Circle())
                            .padding(Spacing.padding1)
                            .background(Color.semantic.light)
                            .clipShape(Circle())
                    }

                    previewSwapButton
                        .padding(.horizontal, Spacing.padding2)

                    DigitPadViewSwiftUI(
                        inputValue: viewStore.binding(get: \.rawInput.suggestion, send: SellEnterAmount.Action.onInputChanged),
                        backspace: {
                            viewStore.send(.onBackspace)
                        }
                    )
                        .frame(height: 230)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .bindings {
                subscribe(
                    viewStore.binding(\.$defaultFiatCurrency),
                    to: blockchain.user.currency.preferred.fiat.trading.currency
                )
            }
            .task {
                await viewStore.send(.streamData).finish()
            }
        }
    }

    @ViewBuilder
    func valuesContainer(
        _ viewStore: ViewStoreOf<SellEnterAmount>
    ) -> some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center) {
                VStack {
                    Text(viewStore.mainFieldText)
                        .typography(.display)
                        .foregroundColor(.semantic.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.1), value: viewStore.isEnteringFiat)
                    Text(viewStore.secondaryFieldText)
                        .typography(.subheading)
                        .foregroundColor(.semantic.text)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.1), value: viewStore.isEnteringFiat)
                }
                .padding(.trailing, Spacing.padding3)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            inputSectionFlipButton(viewStore)
        }
    }

    @MainActor
    private var fromView: some View {
        HStack {
            if let source = viewStore.source {
                source.currencyType.logo()
            } else {
                Icon
                    .selectPlaceholder
                    .color(.semantic.title)
                    .small()
            }

            VStack(alignment: .leading, content: {
                Text(viewStore.source?.assetModel.name ?? LocalizationConstants.Transaction.Sell.Amount.fromLabel)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)

                Text(viewStore.source?.assetModel.code ?? LocalizationConstants.Transaction.Sell.Amount.selectLabel)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
            })
            Spacer()
        }
        .frame(height: 77.pt)
        .padding(.leading, Spacing.padding2)
        .background(Color.semantic.background)
        .onTapGesture {
            viewStore.send(.onSelectSourceTapped)
        }
    }

    @MainActor
    private var targetView: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, content: {
                Text(LocalizationConstants.Transaction.Sell.Amount.forLabel)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)

                Text(viewStore.defaultFiatCurrency?.name ?? "")
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.body)
            })

            viewStore.defaultFiatCurrency?
                .image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .background(Color.WalletSemantic.fiatGreen)
                .cornerRadius(8, corners: .allCorners)
        }
        .frame(height: 77.pt)
        .padding(.trailing, Spacing.padding2)
        .background(Color.semantic.background)
    }

    private func inputSectionFlipButton(
        _ viewStore: ViewStoreOf<SellEnterAmount>
    ) -> some View {
        Button(
            action: {
                viewStore.send(.onChangeInputTapped)
            },
            label: {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(Color.semantic.light)
                    Icon.unfoldMore
                        .color(.semantic.title)
                        .circle(backgroundColor: .semantic.background)
                        .small()
                }
            }
        )
    }

    @ViewBuilder
    private var previewSwapButton: some View {
        if viewStore.transactionDetails.forbidden {
            SecondaryButton(title: viewStore.transactionDetails.ctaLabel, action: {})
        } else {
            PrimaryButton(title: viewStore.transactionDetails.ctaLabel, action: {
                viewStore.send(.onPreviewTapped)
            })
            .disabled(viewStore.previewButtonDisabled)
        }
    }
}
