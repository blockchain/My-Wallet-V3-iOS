// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
@testable import MoneyKitMock
import XCTest

final class CryptoCurrencyTests: XCTestCase {

    private var cryptoCurrencyDesiredOrder: [CryptoCurrency] {
        [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar,
            .mockCoin(symbol: "A", displaySymbol: "A", name: "Custodial 1", sortIndex: 11),
            .mockCoin(symbol: "B", displaySymbol: "B", name: "Custodial 2", sortIndex: 12),
            .mockCoin(symbol: "C", displaySymbol: "C", name: "Custodial 3", sortIndex: 13),
            .mockCoin(symbol: "D", displaySymbol: "D", name: "Custodial 4", sortIndex: 14),
            .mockERC20(symbol: "E", displaySymbol: "E", name: "ERC20 1", sortIndex: 20),
            .mockERC20(symbol: "F", displaySymbol: "F", name: "ERC20 2", sortIndex: 21),
            .mockERC20(symbol: "G", displaySymbol: "G", name: "ERC20 3", sortIndex: 22),
            .mockERC20(symbol: "H", displaySymbol: "H", name: "ERC20 4", sortIndex: 23),
            .mockERC20(symbol: "I", displaySymbol: "I", name: "ERC20 5", sortIndex: 24)
        ]
    }

    func testSortedCryptoCurrencyArrayIsInCorrectOrder() {
        XCTAssertTrue(
            cryptoCurrencyDesiredOrder.shuffled().sorted() == cryptoCurrencyDesiredOrder,
            "sut.allEnabledCryptoCurrencies.sorted() is not as expected."
        )
    }

    func testUniquenessERC20AssetModelIsBasedSolelyOnSymbol() {
        let currencies: [AssetModel] = [
            .mockERC20(symbol: "A", displaySymbol: "A", name: "A", erc20Address: "", sortIndex: 0),
            .mockERC20(symbol: "A", displaySymbol: "X", name: "X", erc20Address: "", sortIndex: 1),
            .mockERC20(symbol: "B", displaySymbol: "B", name: "B", erc20Address: "", sortIndex: 2)
        ]
        let unique = currencies.unique
        XCTAssertEqual(unique.count, 2)
        let set = Set(currencies)
        XCTAssertEqual(set.count, 2)
    }

    func testUniquenessCoinAssetModelIsBasedSolelyOnSymbol() {
        let currencies: [AssetModel] = [
            .mockCoin(symbol: "A", displaySymbol: "A", name: "A", sortIndex: 0),
            .mockCoin(symbol: "A", displaySymbol: "X", name: "X", sortIndex: 1),
            .mockCoin(symbol: "B", displaySymbol: "B", name: "B", sortIndex: 2)
        ]
        let unique = currencies.unique
        XCTAssertEqual(unique.count, 2)
        let set = Set(currencies)
        XCTAssertEqual(set.count, 2)
    }

    func testUniquenessCryptoCurrencyIsBasedSolelyOnSymbol() {
        let currencies: [CryptoCurrency] = [
            .mockERC20(symbol: "A", displaySymbol: "A", name: "A", sortIndex: 0),
            .mockERC20(symbol: "A", displaySymbol: "A", name: "A", sortIndex: 1),
            .mockERC20(symbol: "B", displaySymbol: "B", name: "B", sortIndex: 2),
            .mockCoin(symbol: "A", displaySymbol: "A", name: "A", sortIndex: 0),
            .mockCoin(symbol: "A", displaySymbol: "A", name: "A", sortIndex: 1),
            .mockCoin(symbol: "B", displaySymbol: "B", name: "B", sortIndex: 2)
        ]
        let unique = currencies.unique
        XCTAssertEqual(unique.count, 2)
        let set = Set(currencies)
        XCTAssertEqual(set.count, 2)
    }
}
