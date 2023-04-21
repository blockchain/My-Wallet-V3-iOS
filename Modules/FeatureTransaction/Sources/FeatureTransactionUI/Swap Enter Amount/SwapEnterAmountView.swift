import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureTransactionDomain
import PlatformUIKit
import RxSwift
import SwiftUI
import Localization

public struct SwapEnterAmountView: View {
    let store: StoreOf<SwapEnterAmount>
    @ObservedObject var viewStore: ViewStore<SwapEnterAmount.State, SwapEnterAmount.Action>
    public init(store: StoreOf<SwapEnterAmount>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ZStack {
            Color.semantic.light
            VStack {
                Spacer()
                valuesContainer(viewStore)
                maxButton
                Spacer()
                ZStack(alignment: .center) {
                    HStack(spacing: Spacing.padding1, content: {
                        fromView
                            .cornerRadius(16, corners: .allCorners)
                        targetView
                            .cornerRadius(16, corners: .allCorners)
                    })
                    .frame(height: 77)
                    .padding(.horizontal, Spacing.padding2)

                    Icon
                        .arrowRight
                        .color(.semantic.title)
                        .medium()
                        .circle(backgroundColor: .WalletSemantic.light)
                }

                previewSwapButton
                    .padding(.horizontal, Spacing.padding2)

                DigitPadViewSwiftUI(inputValue: viewStore.binding(\.$inputText))
                    .frame(height: 230)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .bindings {
            subscribe(
                viewStore.binding(\.$sourceValuePrice),
                to: blockchain.api.nabu.gateway.price.crypto[viewStore.source?.code].fiat.quote.value
            )
        }
        .bindings {
            subscribe(
                viewStore.binding(\.$defaultFiatCurrency),
                to: blockchain.user.currency.preferred.fiat.trading.currency
            )
        }
    }

    @ViewBuilder
    func valuesContainer(
        _ viewStore: ViewStoreOf<SwapEnterAmount>
    ) -> some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center) {
                VStack {
                    Text(viewStore.mainFieldText)
                        .typography(.display)
                        .foregroundColor(.semantic.title)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.1), value: viewStore.isEnteringFiat)
                    Text(viewStore.secondaryFieldText)
                        .typography(.subheading)
                        .foregroundColor(.semantic.text)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.1), value: viewStore.isEnteringFiat)
                }
            }
            .frame(maxWidth: .infinity)

            inputSectionFlipButton(viewStore)
        }
    }

    @ViewBuilder
    private var maxButton: some View {
        if let maxString = viewStore.maxAmountToSwap?.toDisplayString(includeSymbol: true) {
            SmallMinimalButton(title: String(format: LocalizationConstants.Swap.maxString, maxString)) {
                viewStore.send(.onMaxButtonTapped)
            }
        }
    }

    @MainActor
    private var fromView: some View {
        HStack {
            if let source = viewStore.source {
                AsyncMedia(url: viewStore.source?.assetModel.logoPngUrl)
                    .frame(width: 24.pt)
                VStack(alignment: .leading, content: {
                    Text(source.assetModel.name)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)

                    Text(source.assetModel.code)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                })
                Spacer()
            } else {
                ProgressView()
            }
        }
        .padding(.leading, Spacing.padding2)
        .background(Color.white)
    }

    @MainActor
    private var targetView: some View {
        HStack {
            if let target = viewStore.target {
                Spacer()
                VStack(alignment: .trailing, content: {
                    Text(target.assetModel.name)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)

                    Text(target.assetModel.code)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                })
                AsyncMedia(url: target.assetModel.logoPngUrl)
                    .frame(width: 24.pt)
            } else {
                ProgressView()
            }
        }
        .padding(.trailing, Spacing.padding2)
        .background(Color.white)
    }

    private func inputSectionFlipButton(
        _ viewStore: ViewStoreOf<SwapEnterAmount>
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
                        .frame(width: 24)
                }
            }
        )
    }

    private var previewSwapButton: some View {
        PrimaryButton(title: LocalizationConstants.Swap.previewSwap, action: {
            viewStore.send(.onPreviewTapped)
        })
    }
}

struct DigitPadViewSwiftUI: UIViewRepresentable {
    typealias UIViewType = DigitPadView
    @Binding var inputValue: String
    private let disposeBag = DisposeBag()

    func makeUIView(context: Context) -> DigitPadView {
        let view = DigitPadView()
        view.viewModel = provideDigitPadViewModel()
        view.viewModel
            .valueRelay
            .subscribe(onNext: { text in
                inputValue = text
            })
            .disposed(by: disposeBag)

        view.viewModel
            .backspaceButtonTapObservable
            .subscribe(onNext: { _ in
                inputValue = "delete"
            })
            .disposed(by: disposeBag)

        return view
    }

    func updateUIView(_ uiView: DigitPadView, context: Context) {}

    private func provideDigitPadViewModel() -> DigitPadViewModel {
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor,
            backgroundColor: .background
        )
    }
}
