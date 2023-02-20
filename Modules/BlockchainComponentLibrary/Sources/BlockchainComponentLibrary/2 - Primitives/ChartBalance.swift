// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Chart Balance from the Figma Component Library
///
/// Used to display the balance and change in value above a line graph
///
///     ChartBalance(
///         title: "Current Balance",
///         balance: "$2,574.37",
///         changeArrow: "↑",
///         changeAmount: "$95.23",
///         changePercentage: "(34.53%)",
///         changeColor: .semantic.success,
///         changeTime: "Past Hour"
///     )
///
/// # Figma
///
/// [ChartBalance](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=1125%3A7633)
public struct ChartBalance: View {
    private let title: String
    private let balance: String
    private let changeArrow: String
    private let changeAmount: String
    private let changePercentage: String
    private let changeColor: Color
    private let changeTime: String?

    /// Create a ChartBalance view
    /// - Parameters:
    ///   - title: Text displayed at the top
    ///   - balance: Large text displayed below the title, eg `$2,571.19`
    ///   - changeArrow: Leading text in change row, usually `↑`, `↓`, or `->`
    ///   - changeAmount: Currency value in change row, eg `$95.23`
    ///   - changePercentage: Percentage for change row, eg `(34.53%)`
    ///   - changeColor: Text color of change row, usually semantic `.success`, `.error`, or `.primary`
    ///   - changeTime: Optional time space of change
    public init(
        title: String,
        balance: String,
        changeArrow: String,
        changeAmount: String,
        changePercentage: String,
        changeColor: Color,
        changeTime: String?
    ) {
        self.title = title
        self.balance = balance
        self.changeArrow = changeArrow
        self.changeAmount = changeAmount
        self.changePercentage = changePercentage
        self.changeColor = changeColor
        self.changeTime = changeTime
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center, spacing: Spacing.baseline) {
                Text(balance)
                    .typography(.title1)
                    .foregroundColor(.semantic.title)

                HStack(spacing: Spacing.baseline) {
                    Group {
                        Text(changeArrow)
                            .typography(.paragraph2)

                        Text(changeAmount)
                            .typography(.paragraph2)

                        Text(changePercentage)
                            .typography(.paragraph2)
                    }
                    .foregroundColor(changeColor)

                    if let changeTime {
                        Text(changeTime)
                            .typography(.paragraph2)
                            .foregroundColor(
                                Color(
                                    light: .palette.grey600,
                                    dark: .palette.white
                                )
                            )
                    }
                }
            }
            .minimumScaleFactor(0.75)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding())
        .padding(.vertical, Spacing.padding2)
    }
}

struct ChartBalance_Previews: PreviewProvider {
    static var previews: some View {
        ChartBalance(
            title: "Current Balance",
            balance: "$2,574.37",
            changeArrow: "↑",
            changeAmount: "$95.23",
            changePercentage: "(34.53%)",
            changeColor: .semantic.success,
            changeTime: "Past Hour"
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Chart Balance")

        ChartBalance(
            title: "Current Balance",
            balance: "$2,574.37",
            changeArrow: "↑",
            changeAmount: "$95.23",
            changePercentage: "(34.53%)",
            changeColor: .semantic.success,
            changeTime: "Past Hour"
        )
        .background(Color.semantic.background)
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .colorScheme(.dark)
        .previewDisplayName("Chart Balance, Dark")

        ChartBalance(
            title: "Current Balance",
            balance: "$2,574.37",
            changeArrow: "↑",
            changeAmount: "$95.23",
            changePercentage: "(34.53%)",
            changeColor: .semantic.success,
            changeTime: nil
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("No time scale")

        ChartBalance(
            title: "Current Balance",
            balance: "$2,574.37",
            changeArrow: "↑",
            changeAmount: "$95.23",
            changePercentage: "(34.53%)",
            changeColor: .semantic.success,
            changeTime: nil
        )
        .background(Color.semantic.background)
        .preferredColorScheme(.dark)
        .colorScheme(.dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("No time scale, Dark")

        ChartBalance(
            title: "Current Balance",
            balance: "$1,000,000,000,000.37",
            changeArrow: "↑",
            changeAmount: "$999,999,999,616.23",
            changePercentage: "(100000000000.53%)",
            changeColor: .semantic.success,
            changeTime: "11 years"
        )
        .previewLayout(.device)
        .previewDisplayName("Chart Balance, Overflow")
    }
}
