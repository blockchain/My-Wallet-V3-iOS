/// Represents a rational number with a numerator and a denominator.
public struct Rational: CustomStringConvertible {

    public private(set) var numerator: Int
    public private(set) var denominator: Int
    public var double: Double { Double(numerator) / Double(denominator) }

    /// Initializes a new Rational with the given numerator and denominator.
    /// - Parameters:
    ///   - numerator: The numerator of the rational number.
    ///   - denominator: The denominator of the rational number.
    public init(numerator: Int, denominator: Int) {
        precondition(denominator != 0, "Denominator must not be zero.")
        self.numerator = numerator
        self.denominator = denominator
    }

    /// Initializes a new Rational by approximating a Double.
    /// - Parameters:
    ///   - x0: The double to approximate.
    ///   - eps: The precision of the approximation. Defaults to 1.0E-6.
    public init(approximating x0: Double, withPrecision eps: Double = 1.0E-6) {
        let (numerator, denominator) = Rational.continuedFractionApproximation(of: x0, withPrecision: eps)
        self.init(numerator: numerator, denominator: denominator)
    }

    /// Approximates a Double using continued fraction expansion.
    /// - Parameters:
    ///   - x0: The double to approximate.
    ///   - eps: The precision of the approximation.
    /// - Returns: A tuple with the numerator and the denominator of the approximation.
    private static func continuedFractionApproximation(of x0: Double, withPrecision eps: Double) -> (Int, Int) {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)

        while x - a > eps * Double(k) * Double(k) {
            x = 1.0 / (x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }

    public var string: String { "\(numerator)/\(denominator)" }
    public var description: String { string }
}

extension Rational {

    /// Adjusts the denominator of the Rational and changes the numerator to match the same ratio.
    /// - Parameter newDenominator: The new denominator for the Rational.
    public func scaled(toDenominator newDenominator: Int) -> Self {
        var copy = self
        copy.scale(toDenominator: newDenominator)
        return copy
    }

    /// Adjusts the denominator of the Rational and changes the numerator to match the same ratio.
    /// - Parameter newDenominator: The new denominator for the Rational.
    public mutating func scale(toDenominator newDenominator: Int) {
        precondition(newDenominator != 0, "New denominator must not be zero.")
        let ratio = Double(numerator) / Double(denominator)
        numerator = Int(round(ratio * Double(newDenominator)))
        denominator = newDenominator
    }

    /// Scales the rational number up or down while preserving its inherent value or ratio.
    /// - Parameter factor: The factor to scale by.
    public func scaled(by factor: Int) -> Self {
        var copy = self
        copy.scale(by: factor)
        return copy
    }

    /// Scales the rational number up or down while preserving its inherent value or ratio.
    /// - Parameter factor: The factor to scale by.
    public mutating func scale(by factor: Int) {
        precondition(factor != 0, "Scale factor must not be zero.")
        self.numerator *= factor
        self.denominator *= factor
    }

    /// Reduces the rational number to its simplest form.
    public mutating func reduce() {
        let gcd = gcd()
        self.numerator /= gcd
        self.denominator /= gcd
    }

    /// Returns the greatest common divisor.
    public func gcd() -> Int {
        gcd(numerator, denominator)
    }

    /// Returns the greatest common divisor (gcd) of two numbers.
    private func gcd(_ a: Int, _ b: Int) -> Int {
        var (a, b) = (a, b)
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return abs(a)
    }

}
