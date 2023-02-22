import Extensions
import SwiftUI

public enum Confetti {

    case shape(AnyShape)
    case image(Image)
    case icon(Icon)
    case view(AnyView)

    @_disfavoredOverload
    public static func shape<S: Shape>(_ shape: S) -> Self {
        .shape(AnyShape(shape))
    }

    @_disfavoredOverload
    public static func view<V: View>(_ view: V) -> Self {
        .view(AnyView(view))
    }

    @ViewBuilder var view: some View {
        switch self {
        case .shape(let s): s
        case .image(let i): i
        case .icon(let i): i
        case .view(let v): v
        }
    }
}

public struct ConfettiConfiguration {

    public init(
        count: Int = 55,
        confetti: [Confetti],
        openingAngle: Angle = .degrees(60),
        closingAngle: Angle = .degrees(120),
        radius: Double = 350,
        duration: TimeInterval = .seconds(3),
        height: Double = CGRect.screen.height,
        fade: Bool = true,
        opacity: Double = 0.8
    ) {
        self.count = count
        self.confetti = confetti
        self.openingAngle = openingAngle
        self.closingAngle = closingAngle
        self.radius = radius
        self.duration = duration
        self.height = height
        self.fade = fade
        self.opacity = opacity
    }

    public var count: Int = 45
    public var confetti: [Confetti]
    public var openingAngle: Angle = .degrees(60)
    public var closingAngle: Angle = .degrees(120)
    public var radius: Double = 350
    public var duration: TimeInterval = .seconds(3)
    public var height: Double = CGRect.screen.height
    public var fade: Bool = true
    public var opacity: Double = 0.8
}

public struct ConfettiCannonView<Container: View>: View {

    let config: ConfettiConfiguration
    var throttle: TimeInterval
    var content: (@escaping () -> Void) -> Container

    @State private var layers: [Date] = []

    public init(
        _ config: ConfettiConfiguration,
        @ViewBuilder _ content: @escaping (@escaping () -> Void) -> Container
    ) {
        self.init(config, throttle: config.duration, content)
    }

    public init(
        _ config: ConfettiConfiguration,
        throttle: TimeInterval,
        @ViewBuilder _ content: @escaping (@escaping () -> Void) -> Container
    ) {
        self.config = config
        self.throttle = throttle
        self.content = content
    }

    public var body: some View {
        ZStack {
            content { tap() }
            ForEach(layers, id: \.self) { layer in
                ConfettiView().id(layer)
            }
        }
        .environment(\.confetti, config)
        .onAppear { layers.append(Date()) }
    }

    func tap() {
        let now = Date()
        if let previous = layers.last, previous.distance(to: now) < throttle { return }
        layers.append(now)
    }
}

public struct ConfettiView: View {

    @Environment(\.confetti) var configuration
    @State var confettis: IndexedCollection<[Confetti]> = [].indexed()

    public init() {}

    public var body: some View {
        ZStack {
            ForEach(confettis, id: \.index) { confetti in
                FloatingConfettiView(confetti: confetti.element)
            }
        }
        .onAppear {
            confettis = (configuration.confetti * configuration.count).randomSample(count: configuration.count).indexed()
        }
    }
}

@MainActor
struct FloatingConfettiView: View {

    @Environment(\.confetti) var configuration

    let confetti: Confetti

    @State var location: CGPoint = .zero
    @State var opacity: Double = 0

    var body: some View {
        AnimatedConfettiView(confetti: confetti)
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear {
                opacity = configuration.opacity
                withAnimation {
                    let closing = (configuration.openingAngle <= configuration.closingAngle ? configuration.closingAngle.degrees : configuration.closingAngle.degrees + 360)
                    let angle: Angle = .degrees(Double.random(in: configuration.openingAngle.degrees ... closing))
                    let distance = pow(.random(in: 0.01...1), 2.0 / 7.0) * configuration.radius
                    location = CGPoint(x: distance * cos(angle.radians), y: -distance * sin(angle.radians))
                }
                Task {
                    try await Task.sleep(nanoseconds: (configuration.duration.u64 / 10) * NSEC_PER_SEC / 1000)
                    withAnimation(.timingCurve(0.12, 0, 0.39, 0, duration: configuration.duration)) {
                        location.y += configuration.height
                        opacity = configuration.fade ? 0 : configuration.opacity
                    }
                }
            }
    }
}

struct AnimatedConfettiView: View {

    var confetti: Confetti

    @State var spin: SIMD3<Double> = SIMD3(Bool.random() ? -1 : 1, 0, Bool.random() ? -1 : 1)
    @State var speed: SIMD3<Double> = SIMD3(.random(in: 0.501...2.201), 0, .random(in: 0.501...2.201))
    @State var move = false
    @State var anchor = CGFloat.random(in: 0...1).rounded()

    var body: some View {
        confetti.view
            .frame(width: 5.vw, height: 5.vw)
            .rotation3DEffect(.degrees(move ? 360 : 0), axis: (x: spin.x, y: 0, z: 0))
            .animation(Animation.linear(duration: speed.x).repeatCount(10, autoreverses: false), value: move)
            .rotation3DEffect(.degrees(move ? 360 : 0), axis: (x: 0, y: 0, z: spin.z), anchor: UnitPoint(x: anchor, y: anchor))
            .animation(Animation.linear(duration: speed.z).repeatForever(autoreverses: false), value: move)
            .onAppear { move = true }
    }
}

@available(iOS, deprecated: 16.0, message: "AnyShape is only useful when targeting iOS versions earlier than 16")
public struct AnyShape: Shape {
    private var makePath: (CGRect) -> Path
    public init<S: Shape>(_ shape: S) {
        makePath = shape.path(in:)
    }
    public func path(in rect: CGRect) -> Path {
        makePath(rect)
    }
}

extension View {

    @warn_unqualified_access public func confetti(_ configuration: ConfettiConfiguration) -> some View {
        environment(\.confetti, configuration)
    }
}

extension EnvironmentValues {

    public var confetti: ConfettiConfiguration {
        get { self[ConfettiConfigurationEnvironmentKey.self] }
        set { self[ConfettiConfigurationEnvironmentKey.self] = newValue }
    }
}

public struct ConfettiConfigurationEnvironmentKey: EnvironmentKey {
    public static let defaultValue: ConfettiConfiguration = ConfettiConfiguration(
        confetti: [
            .icon(.blockchain),
            .image(Image(systemName: "bitcoinsign.circle.fill")),
            .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.success)),
            .view(Triangle().frame(width: 5.pt).foregroundColor(.semantic.error))
        ]
    )
}

public struct Triangle: Shape {

    public init() { }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

struct Preview: PreviewProvider {

    struct Example: View {

        var body: some View {
            ConfettiCannonView(
                ConfettiConfiguration(
                    confetti: [
                        .icon(.blockchain),
                        .image(Image(systemName: "bitcoinsign.circle.fill")),
                        .view(Rectangle().frame(width: 5.pt).foregroundColor(.semantic.success)),
                        .view(Image(systemName: "diamond.fill").foregroundColor(.semantic.error))
                    ]
                )
            ) { action in
                Button("Tap me!", action: action)
            }
            .foregroundColor(.semantic.gold)
        }
    }

    static var previews: some View {
        Example()
    }
}
