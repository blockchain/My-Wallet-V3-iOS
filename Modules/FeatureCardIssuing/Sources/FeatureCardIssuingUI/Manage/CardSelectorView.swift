// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SceneKit
import SwiftUI
import ToolKit
import WebKit

struct CardSelectorView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Manage

    private let store: Store<CardManagementState, CardManagementAction>
    private let isModal: Bool
    @State private var cantOrderCardToasterVisible = false
    @State private var isNextScreenVisible = false

    init(
        store: Store<CardManagementState, CardManagementAction>,
        isModal: Bool = true
    ) {
        self.store = store
        self.isModal = isModal
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if isModal {
                    ZStack(alignment: .trailing) {
                        Text(L10n.Selector.title)
                            .typography(.body1)
                            .frame(maxWidth: .infinity)
                        Icon.closeCirclev2
                            .frame(width: 24, height: 24)
                            .onTapGesture(perform: {
                                viewStore.send(.binding(.set(\.$isCardSelectorPresented, false)))
                            })
                    }
                    .padding(Spacing.padding3)
                }
                ScrollView {
                    VStack(spacing: Spacing.padding2) {
                        HStack {
                            Text(L10n.Selector.myCards)
                                .typography(.subheading)
                            Spacer()
                            SmallMinimalButton(title: L10n.Button.addCard) {
                                guard viewStore.state.canAddCards else {
                                    cantOrderCardToasterVisible = true
                                    return
                                }
                                viewStore.send(CardManagementAction.openAddCardFlow)
                            }
                            .disabled(cantOrderCardToasterVisible)
                        }
                        .padding(.horizontal, Spacing.padding3)
                        ForEach(viewStore.state.cards) { card in
                            CardItemView(
                                card: card,
                                selected: card.id == viewStore.state.selectedCard?.id,
                                onManageTapped: {
                                    if card.status == .initiated {
                                        viewStore.send(.fetchCards)
                                    } else {
                                        viewStore.send(.showCardDetails(card))
                                    }
                                },
                                onViewTapped: {
                                    guard card.status != .initiated else {
                                        return
                                    }
                                    viewStore.send(.selectCard(card.id))
                                    if !isModal {
                                        isNextScreenVisible = true
                                    }
                                }
                            )
                        }
                    }
                }
                if cantOrderCardToasterVisible {
                    AlertCard(
                        title: L10n.Selector.MaxCardNumber.title,
                        message: L10n.Selector.MaxCardNumber.message,
                        variant: .default,
                        onCloseTapped: {
                            cantOrderCardToasterVisible = false
                        }
                    )
                    .padding(Spacing.padding3)
                }
            }
            .onAppear {
                viewStore.send(.fetchCards)
            }
            PrimaryNavigationLink(
                destination: CardManagementView(store: store),
                isActive: $isNextScreenVisible,
                label: EmptyView.init
            )
        }
        .navigationTitle(L10n.Selector.shortTitle)
    }
}

struct CardItemView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Manage.Selector.Button

    let card: Card
    let selected: Bool
    let onManageTapped: () -> Void
    let onViewTapped: () -> Void

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                card.type.image
                    .resizable()
                    .frame(width: 54, height: 88)
                VStack(alignment: .leading) {
                    Text(card.type.localizedLongTitle)
                        .typography(.paragraph2)
                    Text(card.status.localizedString)
                        .typography(.paragraph1)
                        .foregroundColor(card.status.color)
                    SmallMinimalButton(title: card.status == .initiated ? L10n.refresh : L10n.manage) {
                        onManageTapped()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                VStack(alignment: .trailing) {
                    Text("***\(card.last4)")
                        .typography(.paragraph2)
                    Text(card.expiry)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.muted)
                    if selected, card.status != .initiated {
                        SmallPrimaryButton(title: L10n.view) {
                            onViewTapped()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.semantic.light, lineWidth: 1)
        )
        .shadow(color: selected ? Color.semantic.light : .clear, radius: 5, y: 6)
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, selected ? Spacing.padding1 : 0)
        .onTapGesture {
            onViewTapped()
        }
    }
}

extension Card.CardType {

    var image: Image {
        switch self {
        case .physical, .shadow:
            return Image("card-selection", bundle: .cardIssuing)
        case .virtual:
            return Image("card-selection-virtual", bundle: .cardIssuing)
        }
    }
}

#if DEBUG
struct CardSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            CardSelectorView(
                store: .init(
                    initialState: .init(
                        cards: [
                            MockServices.card
                        ],
                        tokenisationCoordinator: .init(service: MockServices())
                    ),
                    reducer: cardManagementReducer,
                    environment: .preview
                ),
                isModal: false
            )
        }
    }
}
#endif
