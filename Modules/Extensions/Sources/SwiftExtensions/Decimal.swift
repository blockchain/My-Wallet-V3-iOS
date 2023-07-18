import Foundation

extension Decimal {

    @inlinable public var doubleValue: Double { (self as NSDecimalNumber).doubleValue }
    @inlinable public func abs() -> Self { Decimal(Swift.abs(doubleValue)) }

    public func roundTo(places: Int, roundingMode: RoundingMode = .bankers) -> Decimal {
        let roundingBehaviour = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: Int16(places),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
        let rounded = (self as NSDecimalNumber)
            .rounding(accordingToBehavior: roundingBehaviour)
        return rounded as Decimal
    }

    public func string(with decimalPrecision: Int, locale: Locale = .current) -> String {
        String(format: "%.\(decimalPrecision)f", locale: locale, doubleValue)
    }
}
