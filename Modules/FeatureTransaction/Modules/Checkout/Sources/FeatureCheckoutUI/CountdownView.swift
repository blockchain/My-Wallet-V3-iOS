// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI
import SwiftUIExtensions

@MainActor
struct CountdownView: View {

    private var deadline: Date
    private let formatter: DateComponentsFormatter = .shortCountdownFormatter

    @Environment(\.scheduler) private var scheduler

    @State private var remaining: String?
    @State private var progress: Double = 0.0
    @State private var opacity: Double = 1

    @Binding private var remainingTime: TimeInterval

    init(deadline: Date, remainingTime: Binding<TimeInterval> = .constant(Int.max.d)) {
        self.deadline = deadline
        _remainingTime = remainingTime
    }

    var body: some View {
        TableRow(
            leading: {
                ProgressView(value: progress)
                    .progressViewStyle(.determinate)
                    .frame(width: 14.pt, height: 14.pt)
                    .padding(.trailing, 8.pt)
            },
            title: {
                if remaining.isNotNil {
                    TableRowTitle(LocalizationConstants.Checkout.Label.countdown)
                        .transition(.opacity)
                }
            },
            trailing: {
                if let remaining {
                    TableRowTitle(remaining)
                } else {
                    TableRowTitle("--:--")
                        .redacted(reason: .placeholder)
                }
            }
        )
        .task(id: deadline, priority: .userInitiated) {
            let start = deadline.timeIntervalSinceNow
            remainingTime = start
            for seconds in stride(from: start, to: 0, by: -1) where seconds > 0 {
                remaining = formatter.string(from: seconds)
                remainingTime = deadline.timeIntervalSinceNow
                withAnimation {
                    progress = min(1 - seconds / start, 1)
                }
                do {
                    try await scheduler.sleep(for: .seconds(1))
                } catch /* a */ { break }
            }
            withAnimation {
                remaining = nil
            }
        }
    }
}

extension DateComponentsFormatter {

    static var shortCountdownFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}
