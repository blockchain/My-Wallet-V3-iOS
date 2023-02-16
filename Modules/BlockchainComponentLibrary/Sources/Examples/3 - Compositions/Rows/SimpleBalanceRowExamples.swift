// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct SimpleBalanceRowExamplesView: View {

    var body: some View {
        ExampleController(selection: 0)
    }

    struct ExampleController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            List {
                SimpleBalanceRow(
                    leadingTitle: "Bitcoin",
                    leadingDescription: "BTC",
                    trailingTitle: "$44,403.13",
                    trailingDescription: "↓ 12.32%",
                    trailingDescriptionColor: .semantic.error,
                    isSelected: Binding(
                        get: {
                            selection == 0
                        },
                        set: { _ in
                            selection = 0
                        }
                    )
                ) {
                    Icon.trade
                        .color(.semantic.warning)
                        .fixedSize()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))

                SimpleBalanceRow(
                    leadingTitle: "Bitcoin",
                    leadingDescription: nil,
                    trailingTitle: "$44,403.13",
                    trailingDescription: nil,
                    trailingDescriptionColor: .semantic.error,
                    isSelected: Binding(
                        get: {
                            selection == 0
                        },
                        set: { _ in
                            selection = 0
                        }
                    )
                ) {
                    Icon.trade
                        .color(.semantic.warning)
                        .fixedSize()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))

                SimpleBalanceRow(
                    leadingTitle: "Bitcoin",
                    leadingDescription: nil,
                    trailingTitle: nil,
                    trailingDescription: nil,
                    trailingDescriptionColor: .semantic.error,
                    isSelected: Binding(
                        get: {
                            selection == 0
                        },
                        set: { _ in
                            selection = 0
                        }
                    )
                ) {
                    Icon.trade
                        .color(.semantic.warning)
                        .fixedSize()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))

                SimpleBalanceRow(
                    leadingTitle: "Blockchain.com Account",
                    leadingDescription: nil,
                    trailingTitle: "$7,926.43",
                    trailingDescription: "0.00039387 BTC",
                    tags: [
                        TagView(text: "No Fees", variant: .success),
                        TagView(text: "Faster", variant: .success),
                        TagView(text: "Warning Alert", variant: .warning)
                    ],
                    isSelected: Binding(
                        get: {
                            selection == 1
                        },
                        set: { _ in
                            selection = 1
                        }
                    )
                ) {
                    Icon.trade
                        .color(.semantic.primary)
                        .fixedSize()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                SimpleBalanceRow(
                    leadingTitle: "BTC - USD",
                    leadingDescription: "Limit Buy - Open",
                    trailingTitle: "0.5736523 BTC",
                    trailingDescription: "$15,482.86",
                    isSelected: Binding(
                        get: {
                            selection == 2
                        },
                        set: { _ in
                            selection = 2
                        }
                    )
                ) {
                    Icon.moneyUSD
                        .color(.semantic.warning)
                        .fixedSize()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            }
            .padding(.vertical, Spacing.padding3)
        }

        @ViewBuilder private var graph: some View {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 16))
                path.addQuadCurve(
                    to: CGPoint(x: 16, y: 8),
                    control: CGPoint(x: 8, y: -8)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 40, y: 6),
                    control: CGPoint(x: 25, y: 20)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 64, y: 8),
                    control: CGPoint(x: 50, y: 0)
                )
            }
            .stroke(Color.semantic.primary, lineWidth: 2)
            .frame(width: 64, height: 16)
        }
    }
}

struct SimpleBalanceRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleBalanceRowExamplesView()
    }
}
