// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RIBs

// MARK: - Builder

protocol PendingTransactionPageBuildable: Buildable {
    func build(
        withListener listener: PendingTransactionPageListener,
        transactionModel: TransactionModel,
        action: AssetAction
    ) -> ViewableRouter<Interactable, ViewControllable>
}

final class PendingTransactionPageBuilder: PendingTransactionPageBuildable {

    let app: AppProtocol

    init(app: AppProtocol = DIKit.resolve()) {
        self.app = app
    }

    func build(
        withListener listener: PendingTransactionPageListener,
        transactionModel: TransactionModel,
        action: AssetAction
    ) -> ViewableRouter<Interactable, ViewControllable> {

        if app.remoteConfiguration.yes(if: blockchain.ux.transaction.pending.transaction.is.enabled) {
            let viewController = UIHostingController(
                rootView: AsyncContentView(
                    source: transactionModel.state.publisher.task { state in
                        try await state.pendingTransactionViewModel.or(throw: "Nil")
                    }.ignoreFailure(),
                    content: { model in
                        PendingTransactionView(model: model)
                    }
                )
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: IconButton(
                        icon: .closeCirclev2,
                        action: { [app] in app.post(event: blockchain.ux.transaction.action.reset) }
                    )
                )
                .app(app)
            )
            return ViewableRouter(
                interactor: Interactor(),
                viewController: viewController
            )
        }

        let viewController = PendingTransactionViewController()
        let interactor = PendingTransactionPageInteractor(
            transactionModel: transactionModel,
            presenter: viewController,
            action: action
        )
        interactor.listener = listener

        return ViewableRouter(interactor: interactor, viewController: viewController)
    }
}

extension TransactionState {

    typealias L10n = LocalizationConstants.Activity.MainScreen.Item

    var pendingTransactionViewModel: PendingTransactionView.Model? {
        get async throws {
            // TODO: this should be driven via the order API
            let old = try await PendingTransctionStateProviderFactory.pendingTransactionStateProvider(action: action)
                .connect(state: .just(self))
                .await()
            switch executionStatus {
            case .inProgress:
                return .init(
                    state: .inProgress(
                        UX.Dialog(
                            title: old.title.text,
                            message: old.subtitle.text
                        )
                    ),
                    currency: destination!.currencyType
                )
            case .completed:
                return .init(
                    state: .success(
                        UX.Dialog(
                            title: old.title.text,
                            message: old.subtitle.text,
                            actions: .default
                        )
                    ),
                    currency: destination!.currencyType
                )
            default:
                return nil
            }
        }
    }
}

import BlockchainUI
import SwiftUI

@MainActor
struct PendingTransactionView: View {

    struct Model {
        var state: ViewState
        var currency: CurrencyType
    }

    enum ViewState {
        case inProgress(UX.Dialog)
        case success(UX.Dialog)
    }

    let model: Model
    var viewState: ViewState { model.state }

    init(model: Model) {
        self.model = model
    }

    var confetti: ConfettiConfiguration {
        ConfettiConfiguration(
            confetti: [
                .icon(.blockchain.color(.semantic.primary)),
                .view(model.currency.logoResource.view.clipShape(Circle())),
                .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.success)),
                .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.gold))
            ]
        )
    }

    var body: some View {
        VStack {
            switch viewState {
            case .inProgress(let progress):
                PendingTransactionDialogView(progress, currency: model.currency)
            case .success(let success):
                ConfettiCannonView(confetti) { action in
                    PendingTransactionDialogView(success, currency: model.currency, isLoading: false)
                        .onTapGesture(perform: action)
                }
            }
        }
    }
}

struct PendingTransactionDialogView<Footer: View>: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let story = blockchain.ux.transaction.pending.transaction
    let dialog: UX.Dialog
    let isLoading: Bool
    let currency: CurrencyType

    let footer: Footer

    init(
        _ dialog: UX.Dialog,
        currency: CurrencyType,
        isLoading: Bool = true,
        @ViewBuilder footer: () -> Footer = EmptyView.init
    ) {
        self.dialog = dialog
        self.currency = currency
        self.isLoading = isLoading
        self.footer = footer()
    }

    var body: some View {
        VStack {
            VStack(spacing: .none) {
                Spacer()
                icon
                content
                Spacer()
                footer
                Spacer()
            }
            .multilineTextAlignment(.center)
            actions
        }
        .background(Color.semantic.background)
        .padding()
    }

    let overlay: Double = 7.5

    @ViewBuilder
    private var icon: some View {
        currency.logoResource.view
            .scaledToFit()
            .frame(maxHeight: 100.pt)
            .padding((overlay / 2.d).i.vmin)
            .overlay(
                Group {
                    ZStack {
                        Circle()
                            .foregroundColor(.semantic.background)
                            .scaleEffect(1.3)
                        Group {
                            if isLoading {
                                ProgressView(value: 0.25)
                                    .progressViewStyle(BlockchainCircularProgressViewStyle())
                            } else {
                                Icon.checkCircle
                                    .color(.semantic.success)
                            }
                        }
                        .scaleEffect(0.9)
                    }
                    .frame(
                        width: overlay.vmin,
                        height: overlay.vmin
                    )
                    .offset(x: -overlay, y: -overlay)
                },
                alignment: .bottomTrailing
            )
    }

    @ViewBuilder var content: some View {
        if dialog.title.isNotEmpty {
            Text(rich: dialog.title)
                .typography(.title3)
                .foregroundColor(.semantic.title)
                .padding(.bottom, Spacing.padding1.pt)
        }
        if dialog.message.isNotEmpty {
            Text(rich: dialog.message)
                .typography(.body1)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding2.pt)
        }
    }

    @ViewBuilder
    private var actions: some View {
        let actions = dialog.actions.or(default: [])
        VStack(spacing: Spacing.padding1) {
            ForEach(actions.prefix(2).indexed(), id: \.element) { index, action in
                if action.title.isNotEmpty {
                    if index == actions.startIndex {
                        PrimaryButton(
                            title: action.title,
                            action: { post(action) }
                        )
                    } else {
                        MinimalButton(
                            title: action.title,
                            action: { post(action) }
                        )
                    }
                }
            }
        }
    }

    private func post(_ action: UX.Action) {
        switch action.url {
        case let url?:
            app.post(
                event: story.footer.action.then.launch.url,
                context: context + [
                    blockchain.ui.type.action.then.launch.url: url
                ]
            )
        case nil:
            app.post(event: story.footer.action.then.close, context: context)
        }
    }
}
