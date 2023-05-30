// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit

public struct ERC20ContractGasActivityModel {

    public let cryptoCurrency: CryptoCurrency
    public let cryptoValue: CryptoValue?
    public let to: EthereumAddress?

    public init?(details: EthereumActivityItemEventDetails) {
        guard let cryptoCurrency = ERC20ContractGasActivityModel.token(address: details.to) else {
            return nil
        }
        self.cryptoCurrency = cryptoCurrency
        switch ERC20Function(data: details.data) {
        case .transfer(to: let address, amount: let hexAmount):
            self.cryptoValue = ERC20ContractGasActivityModel.gasCryptoValue(
                hexAmount: hexAmount,
                cryptoCurrency: cryptoCurrency
            )
            self.to = EthereumAddress(address: address, network: .ethereum)
        case nil:
            self.cryptoValue = nil
            self.to = nil
        }
    }

    private static func gasCryptoValue(hexAmount: String?, cryptoCurrency: CryptoCurrency) -> CryptoValue? {
        guard
            let hexAmount,
            let decimalAmount = BigInt(hexAmount, radix: 16)
        else { return nil }
        return CryptoValue.create(minor: decimalAmount, currency: cryptoCurrency)
    }

    private static func token(address: EthereumAddress) -> CryptoCurrency? {
        CryptoCurrency(
            erc20Address: address.publicKey.lowercased(),
            service: EnabledCurrenciesService.default
        )
    }
}
