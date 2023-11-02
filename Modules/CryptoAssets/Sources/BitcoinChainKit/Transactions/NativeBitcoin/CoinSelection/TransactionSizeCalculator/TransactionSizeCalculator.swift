// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import ToolKit

protocol TransactionSizeCalculating {
    func transactionBytes(
        inputs: TransactionSizeCalculatorQuantities,
        outputs: TransactionSizeCalculatorQuantities
    ) -> Decimal

    func dustThreshold(
        for feePerByte: BigUInt,
        type: BitcoinScriptType
    ) -> Decimal

    func effectiveBalance(
        for feePerByte: BigUInt,
        inputs: [UnspentOutput],
        outputs: TransactionSizeCalculatorQuantities
    ) -> BigUInt
}

struct TransactionSizeCalculator: TransactionSizeCalculating {

    /// The total bytes used for a transaction with the given inputs and outputs.
    func transactionBytes(
        inputs: TransactionSizeCalculatorQuantities,
        outputs: TransactionSizeCalculatorQuantities
    ) -> Decimal {
        var vBytesTotal: Decimal = 0

        vBytesTotal += inputs.vBytesTotalInput
        vBytesTotal += outputs.vBytesTotalOutput

        var overhead: Decimal = overhead(for: inputs)

        overhead += 4 // nVersion
        overhead += varIntLength(inputs.count)
        overhead += varIntLength(outputs.count)
        overhead += 4 // nLockTime

        return vBytesTotal + overhead
    }

    func dustThreshold(
        for feePerByte: BigUInt,
        type: BitcoinScriptType
    ) -> Decimal {
        let cost = TransactionCost.PerInput.for(type) + TransactionCost.PerOutput.for(type)
        let feePerByte = feePerByte.decimal
        let dustThreshold = cost * feePerByte
        return dustThreshold.roundTo(places: 0, roundingMode: .up)
    }

    func effectiveBalance(
        for feePerByte: BigUInt,
        inputs: [UnspentOutput],
        outputs: TransactionSizeCalculatorQuantities
    ) -> BigUInt {
        let feePerByte = feePerByte.decimal
        let transactionBytes = transactionBytes(
            inputs: .init(unspentOutputs: inputs),
            outputs: outputs
        )
        let cost = (transactionBytes * feePerByte).roundTo(places: 0, roundingMode: .up)
        let balance = inputs.sum()
        let costBig = BigUInt((cost as NSDecimalNumber).stringValue)!
        guard balance > costBig else {
            return .zero
        }
        return balance - costBig
    }

    /// Counts the number of digits that a certain number of inputs will consume.
    private func varIntLength(_ number: UInt) -> Decimal {
        switch number {
        case let x where x < 0xfd:
            1
        case let x where x <= 0xffff:
            3
        case let x where x <= 0xffffffff:
            5
        default:
            9
        }
    }

    private func overhead(for inputs: TransactionSizeCalculatorQuantities) -> Decimal {
        if inputs.hasWitness {
            let vBytesPerWeightUnit: Decimal = 4
            // segwit marker + segwit flag + witness element count
            return 0.25 + 0.25 + varIntLength(inputs.count) / vBytesPerWeightUnit
        } else {
            // No overhead for non-segwit.
            return 0
        }
    }
}
