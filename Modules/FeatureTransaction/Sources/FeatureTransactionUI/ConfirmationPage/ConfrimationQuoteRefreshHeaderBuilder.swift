// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit

class ConfrimationQuoteRefreshHeaderBuilder: HeaderBuilder {

    var defaultHeight: CGFloat = 32

    let expirationDate: Date

    init(_ expirationDate: Date) {
        self.expirationDate = expirationDate
    }

    func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView? {
        let uiView = UIHostingController(
            rootView: CountDownView(
                secondsRemaining: expirationDate.timeIntervalSinceNow
            )
        ).view
        uiView?.frame = CGRect(x: 0, y: 0, width: width, height: customHeight ?? defaultHeight)
        return uiView
    }
}

import Combine
import SwiftUI

struct CountDownView: View {
    private var initialTime: TimeInterval

    @State private var secondsRemaining: TimeInterval
    @State var progressValue: Double = 0.0

    let countdownFormatter: DateComponentsFormatter = .shortCountdownFormatter

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(secondsRemaining: TimeInterval) {
        self.initialTime = secondsRemaining
        self.secondsRemaining = secondsRemaining
    }

    var body: some View {
        HStack {
            ProgressCircle(progress: $progressValue)
                .frame(width: 14.0, height: 14.0)

            if let timeString = countdownFormatter.string(from: secondsRemaining) {
                Text("New Quote in: \(timeString)")
                    .typography(.caption2)
                    .onReceive(timer) { _ in
                        guard secondsRemaining > 0 else { return }
                        secondsRemaining -= 1
                        progressValue = 1 - secondsRemaining / initialTime
                    }
            }
        }
    }
}

struct ProgressCircle: View {
    @Binding var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2.0)
                .opacity(0.5)
                .foregroundColor(Color.semantic.primaryMuted)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.semantic.primary)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}
