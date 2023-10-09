import SwiftExtensions

public actor ExponentialBackoff {

    var n = 0
    var rng: RandomNumberGenerator
    let unit: TimeInterval

    public init(
        unit: TimeInterval = 0.5,
        rng: RandomNumberGenerator = SystemRandomNumberGenerator()
    ) {
        self.unit = unit
        self.rng = rng
    }

    public func next() async throws {
        n = min(n + 1, 15)
        let time = unit * TimeInterval.random(
            in: 1...pow(2, n.d),
            using: &rng
        )
        try await Task.sleep(
            nanoseconds: min(time * NSEC_PER_SEC.d, UInt64.max.d).u64
        )
    }

    public func reset() { n = 0 }
    public func count() -> Int { n }
}
