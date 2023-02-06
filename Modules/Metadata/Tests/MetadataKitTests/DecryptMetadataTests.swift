// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class DecryptMetadataTests: XCTestCase {

    func test_decryptMetadata() throws {

        let expectedEntry = EthereumEntryPayload.entry

        let envionment = TestEnvironment()

        let key = envionment.metadataState.metadataNodes.metadataNode

        let metadata = try MetadataNode
            .from(
                metaDataHDNode: key,
                metadataDerivation: MetadataDerivation(),
                for: .ethereum
            )
            .get()

        let payload = "6hkh/9FX1/MvNi1S5bLU/v2OcQ0tC15qidio+dVXVOIzALcakViBdqoLoTN2I/jN3OC8vQWeDjtgBXJoo5PPMXcXZK8cXW3OwPUNZwS1uO+k3MQWck45FSnmURCwzqwNC5SKY9KKRb9jGzHxSdDuYImQoJQWzXtt9tYCKjB5CF3SZESu6aTjB3Dqo43vVfaAohLXFyV4fpEptkW5Qut+7KbMW0xsoxsVahJpSCfiJoeMZ6SOaa6u2k6+0azyvCrsHsadyUGMyJyDELND/jFYx8hD3NyuUJ6e4dRXtL7GnxPAGZTHyM9jZe0eGecRosIY"

        let decrypted = try
            decryptMetadata(
                metadata: metadata,
                payload: payload
            )
            .get()

        // swiftlint:disable:next force_try
        let encoded = try! JSONDecoder().decode(
            EthereumEntryPayload.self,
            from: Data(decrypted.utf8)
        )

        XCTAssertEqual(encoded, expectedEntry)
    }
}
