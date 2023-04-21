// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import SwiftUI

struct CountDownView: View {
    private var initialTime: TimeInterval

    private var onComplete: (() -> Void)?
    @State private var secondsRemaining: TimeInterval
    @State var progressValue: Double = 0.0

    let countdownFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        secondsRemaining: TimeInterval,
        onComplete: (() -> Void)? = nil
    ) {
        self.initialTime = secondsRemaining
        self.onComplete = onComplete
        self.secondsRemaining = secondsRemaining
    }

    var body: some View {
        HStack {
            if let timeString = countdownFormatter.string(from: secondsRemaining) {
                ProgressView(value: progressValue)
                  .progressViewStyle(.determinate)
                  .frame(width: 14.0, height: 14.0)
                Text(L10n.countdown.interpolating(timeString))
                    .typography(.micro)
                    .foregroundColor(.semantic.text)
                    .onReceive(timer) { _ in
                        guard secondsRemaining > 0 else {
                            onComplete?()
                            return
                        }
                        secondsRemaining -= 1
                        progressValue = 1 - secondsRemaining / initialTime
                    }
            }
        }
    }
}
