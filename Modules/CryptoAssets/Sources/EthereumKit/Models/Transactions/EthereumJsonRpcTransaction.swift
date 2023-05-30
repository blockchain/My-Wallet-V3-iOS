// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A representation of a  transaction that can be passed to Ethereum JSON RPC methods.
///
/// All parameters are hexadecimal String values.
public struct EthereumJsonRpcTransaction: Codable {

    /// from: DATA, 20 Bytes - The address the transaction is send from.
    let from: String

    /// to: DATA, 20 Bytes - (optional when creating new contract) The address the transaction is directed to.
    let to: String?

    /// data: DATA - The compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see Ethereum Contract ABI
    let data: String

    /// gas: QUANTITY - (optional, default: 90000) Integer of the gas provided for the transaction execution. It will return unused gas.
    let gas: String?

    /// gasPrice: QUANTITY - (optional, default: To-Be-Determined) Integer of the gasPrice used for each paid gas
    let gasPrice: String?

    /// value: QUANTITY - (optional) Integer of the value sent with this transaction
    let value: String?

    /// nonce: QUANTITY - (optional) Integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce.
    let nonce: String?

    enum Keys: CodingKey {
        case from
        case to
        case data
        case gas
        case gasPrice
        case value
        case nonce
    }

    public init(
        from: String,
        to: String?,
        data: String,
        gas: String?,
        gasPrice: String?,
        value: String?,
        nonce: String?
    ) {
        self.from = from
        self.to = to
        self.data = data
        self.gas = gas
        self.gasPrice = gasPrice
        self.value = value
        self.nonce = nonce
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        from = try container.decode(String.self, forKey: .from)
        to = try container.decodeIfPresent(String.self, forKey: .to)
        data = try container.decode(String.self, forKey: .data).sanizeHexString
        gas = try container.decodeIfPresent(String.self, forKey: .gas)?.sanizeHexString.withoutLeadingZeroes
        gasPrice = try container.decodeIfPresent(String.self, forKey: .gasPrice)?.sanizeHexString.withoutLeadingZeroes
        value = try container.decodeIfPresent(String.self, forKey: .value)?.sanizeHexString.withoutLeadingZeroes
        nonce = try container.decodeIfPresent(String.self, forKey: .nonce)?.sanizeHexString.withoutLeadingZeroes
    }
}

extension String {
    var sanizeHexString: String {
        var hex = hasHexPrefix ? self.withoutHex : self
        if hex.isEmpty {
            return ""
        }
        hex = hex.count % 2 != 0 ? "0" + hex : hex
        return "0x\(hex)"
    }

    var withoutLeadingZeroes: String {
        let sanitized = replacingOccurrences(of: "(?<=0x)0+", with: "", options: .regularExpression)
        guard sanitized != "0x" else {
            return "0x0"
        }
        return sanitized
    }
}
