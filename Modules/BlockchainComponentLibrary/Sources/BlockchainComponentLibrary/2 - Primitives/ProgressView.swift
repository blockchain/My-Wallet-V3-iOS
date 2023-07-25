// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Extensions
import SwiftUI

public struct BlockchainProgressView: View {
    @BlockchainApp var app
    public init() {}

    public var body: some View {
        ProgressView()
            .progressViewStyle(.blockchain)
            .frame(width: 15.vw, height: 15.vh)
    }
}

public struct BlockchainProgressViewStyle: ProgressViewStyle {
    @Environment(\.scheduler) var scheduler
    var timeOutEventTag: Tag.Event = BlockchainNamespace.blockchain.ux.loading.indicator.event.did.timeout
    @State private var timeout: Int = 1
    @BlockchainApp var app

    public func makeBody(configuration: Configuration) -> some View {
        LottieView(json: "loader".data())
            .scaledToFit()
            .task {
                do {
                    try await scheduler.sleep(for: .seconds(timeout))
                    $app.post(event: timeOutEventTag)
                } catch {
                    // cancelled, don't worry!
                }
            }
            .bindings {
                subscribe($timeout, to: BlockchainNamespace.blockchain.app.configuration.loading.indicator.timeout)
            }
    }
}

extension ProgressViewStyle where Self == BlockchainCircularProgressViewStyle {
    public static var blockchain: BlockchainProgressViewStyle { .init() }
}

public struct BlockchainCircularProgressViewStyle: ProgressViewStyle {

    public var stroke: Color
    public var background: Color

    public var lineWidth: Length
    public var duration: TimeInterval
    public var indeterminate: Bool
    public var lineCap: CGLineCap

    public init(
        stroke: Color = Color.blue,
        background: Color = Color.blue.opacity(0.3),
        lineWidth: Length = (100 / 6).pmin,
        duration: TimeInterval = 1,
        indeterminate: Bool = true,
        lineCap: CGLineCap = .butt
    ) {
        self.stroke = stroke
        self.background = background
        self.lineWidth = lineWidth
        self.duration = duration
        self.indeterminate = indeterminate
        self.lineCap = lineCap
    }

    @State private var angle: Angle = .degrees(-90)
    @Environment(\.scheduler) var scheduler
    var timeOutEventTag: Tag.Event = BlockchainNamespace.blockchain.ux.loading.indicator.event.did.timeout
    @State private var timeout: Int = 1
    @BlockchainApp var app


    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let lineWidth = lineWidth.in(geometry)
            ZStack {
                let style = StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: lineCap
                )
                Circle()
                    .stroke(background, style: style)
                Circle()
                    .trim(from: 0, to: (configuration.fractionCompleted ?? 0.3).cg)
                    .stroke(stroke, style: style)
                    .rotationEffect(angle)
                    .onAppear {
                        if indeterminate {
                            DispatchQueue.main.async {
                                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                                    angle = .degrees(angle.degrees + 360)
                                }
                            }
                        }
                    }
                    .task {
                        do {
                            try await scheduler.sleep(for: .seconds(timeout))
                            $app.post(event: timeOutEventTag)
                        } catch {
                            // cancelled, don't worry!
                        }
                    }
                    .bindings {
                        subscribe($timeout, to: BlockchainNamespace.blockchain.app.configuration.loading.indicator.timeout)
                    }
            }
            .padding(lineWidth / 2)
        }
        .scaledToFit()
    }
}

extension ProgressViewStyle where Self == BlockchainCircularProgressViewStyle {
    public static var indeterminate: BlockchainCircularProgressViewStyle { .init() }
    public static var determinate: BlockchainCircularProgressViewStyle { .init(indeterminate: false) }
}

#if DEBUG
struct IndeterminateProgressStyle_Previews: PreviewProvider {

    static var previews: some View {
        ProgressView()
            .progressViewStyle(.blockchain)
            .frame(width: 15.vw, height: 15.vh)
            .padding()
        ProgressView(value: 0.25)
            .progressViewStyle(.indeterminate)
            .padding()
    }
}
#endif


public struct IndeterminateProgressView: View {
    @BlockchainApp var app

    public init() {}

    public var body: some View {
        ProgressView()
            .frame(width: 25.vw, height: 25.vh)
            .progressViewStyle(.indeterminate)
    }
}
