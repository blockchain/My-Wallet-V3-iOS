// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureCheckoutDomain
import SwiftUI

public struct SendCheckoutView<Object: LoadableObject>: View where Object.Output == SendCheckout, Object.Failure == Never {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewModel: Object

    var onMemoUpdated: (SendCheckout.Memo) -> Void

    public init(viewModel: Object, onMemoUpdated: @escaping (SendCheckout.Memo) -> Void) {
        _viewModel = .init(wrappedValue: viewModel)
        self.onMemoUpdated = onMemoUpdated
    }

    public var body: some View {
        AsyncContentView(
            source: viewModel,
            loadingView: Loading(),
            content: { [onMemoUpdated] in Loaded(checkout: $0, onMemoUpdated: onMemoUpdated) }
        )
        .onAppear {
            app.post(
                event: blockchain.ux.transaction.checkout[].ref(to: context),
                context: context
            )
        }
    }
}

extension SendCheckoutView {

    public init<P>(
        publisher: P,
        onMemoUpdated: @escaping (SendCheckout.Memo) -> Void
    ) where P: Publisher, P.Output == SendCheckout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        self.viewModel = PublishedObject(publisher: publisher)
        self.onMemoUpdated = onMemoUpdated
    }

    public init(
        _ checkout: Object.Output,
        onMemoUpdated: @escaping (SendCheckout.Memo) -> Void
    ) where Object == PublishedObject<Just<SendCheckout>, DispatchQueue> {
        self.init(publisher: Just(checkout), onMemoUpdated: onMemoUpdated)
    }
}

extension SendCheckoutView {

    public struct Loading: View {

        public var body: some View {
            ZStack {
                SendCheckoutView.Loaded(checkout: .preview, onMemoUpdated: { _ in })
                    .redacted(reason: .placeholder)
                ProgressView()
            }
        }
    }

    public struct Loaded: View {

        @BlockchainApp var app
        @Environment(\.context) var context

        @StateObject private var memoState: InternalMemoState
        @State private var isFirstResponder: Bool = false
        private var onMemoUpdated: (SendCheckout.Memo) -> Void

        let checkout: SendCheckout

        public init(checkout: SendCheckout, onMemoUpdated: @escaping (SendCheckout.Memo) -> Void) {
            self.checkout = checkout
            self.onMemoUpdated = onMemoUpdated
            let memoValue = checkout.memo?.value ?? ""
            let memoRequired = checkout.memo?.required ?? false
            self._memoState = StateObject(
                wrappedValue: InternalMemoState(text: memoValue, required: memoRequired)
            )
        }
    }
}

extension SendCheckoutView.Loaded {

    public var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            List {
                Section {
                    rows()
                } header: {
                    header()
                }
                if let memo = checkout.memo {
                    Section {
                        memoRow(memo: memo)
                    }
                }
            }
            .listStyle(.insetGrouped)
            footer()
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle(L10n.NavigationTitle.send.interpolating(checkout.currencyType.name))
        .backgroundTexture(.semantic.background)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    func header() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: Spacing.padding1) {
                if let mainValue = checkout.amountDisplayTitles.title {
                    Text(mainValue)
                        .typography(.title1)
                        .foregroundColor(.semantic.title)
                }
                Text(checkout.amountDisplayTitles.subtitle ?? "")
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            .padding(.bottom, Spacing.padding3)
            .background(Color.clear)
            Spacer()
        }
    }

    func rows() -> some View {
        Group {
            from()
            to()
            fees()
            total()
        }
        .listRowInsets(.zero)
        .frame(height: 80)
    }

    func from() -> some View {
        TableRow(
            title: .init(L10n.Label.from),
            trailingTitle: .init(checkout.from.name)
        )
    }

    func to() -> some View {
        TableRow(
            title: .init(L10n.Label.to),
            trailingTitle: .init(checkout.to.name)
        )
    }

    @ViewBuilder
    func fees() -> some View {
        switch checkout.fee.type {
        case .network:
            TableRow(
                title: .init(L10n.Label.networkFees),
                byline: { TagView(text: checkout.fee.type.tagTitle, variant: .outline) },
                trailingTitle: .init(checkout.fee.value.toDisplayString(includeSymbol: true)),
                trailingByline: .init(checkout.fee.exchange?.toDisplayString(includeSymbol: true) ?? "")
            )
        case .processing:
            TableRow(
                title: .init(L10n.Label.processingFees),
                trailingTitle: .init(checkout.fee.exchange?.toDisplayString(includeSymbol: true) ?? ""),
                trailingByline: .init(checkout.fee.value.toDisplayString(includeSymbol: true))
            )
        }
    }

    @ViewBuilder
    func total() -> some View {
        TableRow(
            title: .init(L10n.Label.total),
            trailingTitle: .init(checkout.totalDisplayTitles.title),
            trailingByline: .init(checkout.totalDisplayTitles.subtitle)
        )
    }

    @ViewBuilder
    func memoRow(memo: SendCheckout.Memo) -> some View {
        TableRow(
            title: L10n.Label.memo + memo.suffixIfRequired,
            footer: {
                VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                    memoTextfield(memo: memo)
                        .onReceive(
                            memoState.$memo,
                            perform: { memo in
                                let memo = SendCheckout.Memo(value: memo.value, required: memo.required)
                                onMemoUpdated(memo)
                            }
                        )
                    if memo.required {
                        Text(L10n.Label.memoRequiredCaption.interpolating(checkout.amount.value.currency.name))
                            .typography(.caption1)
                            .foregroundColor(.semantic.text)
                    }
                }
            }
        )
        .listRowInsets(.zero)
        .frame(minHeight: 100)
    }

    func footer() -> some View {
        VStack(spacing: .zero) {
            PrimaryButton(
                title: L10n.Button.confirm,
                action: {
                    app.post(
                        event: blockchain.ux.transaction.checkout.confirmed[].ref(to: context),
                        context: context
                    )
                }
            )
        }
        .padding()
    }

    @ViewBuilder
    private func memoTextfield(memo: SendCheckout.Memo) -> some View {
        if #available(iOS 15, *) {
            TextField(L10n.Label.memoPlaceholder, text: $memoState.inputText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedTextFieldStyle())
                .typography(.body1)
        } else {
            Input(
                text: $memoState.inputText,
                isFirstResponder: $isFirstResponder,
                shouldResignFirstResponderOnReturn: true,
                placeholder: L10n.Label.memoPlaceholder,
                configuration: { textField in
                    textField.isSecureTextEntry = false
                    textField.autocorrectionType = .no
                    textField.autocapitalizationType = .none
                }
            )
        }
    }
}

class InternalMemoState: ObservableObject {
    @Published var inputText: String
    @Published var memo: SendCheckout.Memo

    init(text: String, required: Bool) {
        self.inputText = text
        self.memo = .init(value: text, required: required)

        $inputText
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { SendCheckout.Memo(value: $0, required: required) }
            .assign(to: &$memo)
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, Spacing.padding2)
            .padding(.horizontal, 12)
            .background(
                Color.semantic.light
            )
            .cornerRadius(Spacing.padding1)
    }
}

// MARK: Titles

extension SendCheckout {
    var amountDisplayTitles: (title: String?, subtitle: String?) {
        if isSourcePrivateKey {
            return (
                amount.value.toDisplayString(includeSymbol: true),
                amount.fiatValue?.toDisplayString(includeSymbol: true)
            )
        } else {
            return (
                amount.fiatValue?.toDisplayString(includeSymbol: true),
                amount.value.toDisplayString(includeSymbol: true)
            )
        }
    }

    var totalDisplayTitles: (title: String, subtitle: String) {
        if isSourcePrivateKey {
            return (
                total.value.toDisplayString(includeSymbol: true),
                total.fiatValue?.toDisplayString(includeSymbol: true) ?? ""
            )
        } else {
            return (
                total.fiatValue?.toDisplayString(includeSymbol: true) ?? "",
                total.value.toDisplayString(includeSymbol: true)
            )
        }
    }
}
