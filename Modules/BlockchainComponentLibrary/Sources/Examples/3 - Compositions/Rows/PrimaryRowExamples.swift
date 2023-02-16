// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct PrimaryRowExamplesView: View {

    var body: some View {
        ExampleController(selection: 0)
    }

    struct ExampleController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            ScrollView {
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Trading",
                            subtitle: "Buy & Sell",
                            action: {
                                selection = 0
                            }
                        )

                        PrimaryRow(
                            title: "Email Address",
                            subtitle: "satoshi@blockchain.com",
                            tags: [TagView(text: "Confirmed", variant: .success)],
                            action: {
                                selection = 1
                            }
                        )

                        PrimaryRow(
                            title: "From: BTC Blockchain.com Account",
                            subtitle: "To: 0x093871209487120934812027675",
                            action: {
                                selection = 2
                            }
                        )

                        PrimaryRow(
                            title: "Link a Bank",
                            subtitle: "Instant Connection",
                            description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                            tags: [
                                TagView(text: "Fastest", variant: .success),
                                TagView(text: "Warning Alert", variant: .warning)
                            ],
                            action: {
                                selection = 3
                            }
                        )

                        PrimaryRow(
                            title: "Cloud Backup",
                            subtitle: "Buy & Sell",
                            trailing: {
                                Switch()
                            }
                        )
                    }
                }
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Features and Limits",
                            action: {
                                selection = 5
                            }
                        )

                        PrimaryRow(
                            title: "Back Up Your Wallet",
                            subtitle: "Step 1",
                            leading: {
                                Icon.wallet
                                    .color(.semantic.dark)
                                    .fixedSize()
                            },
                            action: {
                                selection = 6
                            }
                        )

                        PrimaryRow(
                            title: "Gold Level",
                            subtitle: "Higher Trading Limits",
                            tags: [TagView(text: "Approved", variant: .success)],
                            leading: {
                                Icon.apple
                                    .color(.semantic.orangeBG)
                                    .fixedSize()
                            },
                            action: {
                                selection = 7
                            }
                        )
                    }
                }
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Trade",
                            subtitle: "BTC -> ETH",
                            leading: {
                                Icon.trade
                                    .color(.semantic.success)
                                    .fixedSize()
                            },
                            action: {
                                selection = 8
                            }
                        )

                        PrimaryRow(
                            title: "Link a Bank",
                            subtitle: "Instant Connection",
                            description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                            tags: [
                                TagView(text: "Fastest", variant: .success),
                                TagView(text: "Warning Alert", variant: .warning)
                            ],
                            leading: {
                                Icon.bank
                                    .color(.semantic.primary)
                                    .fixedSize()
                            },
                            action: {
                                selection = 9
                            }
                        )

                        PrimaryRow(
                            title: "Features and Limits",
                            leading: {
                                Icon.blockchain
                                    .color(.semantic.primary)
                                    .fixedSize()
                            },
                            action: {
                                selection = 10
                            }
                        )
                    }
                }
            }
        }
    }

    private struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}

struct PrimaryRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryRowExamplesView()
    }
}
