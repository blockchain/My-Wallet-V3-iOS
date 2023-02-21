// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit
import XCTest

class PayloadCryptoTests: XCTestCase {

    private var subject: PayloadCrypto!

    override func setUpWithError() throws {
        try super.setUpWithError()

        subject = PayloadCrypto(cryptor: AESCryptor())
    }

    override func tearDownWithError() throws {
        subject = nil

        try super.tearDownWithError()
    }

    func test_decryptWallet_v1() throws {
        let data = "OPWBr1rsrvGsbNpIidlztqc0YsPwS0gg51rz6gWlrsJzY+VidziSekuiy7AcxVF42sMcJp9XD41xPsmq0m9yEWrFw6QufwLjSWNE4IK8mD6jIYH35a7fWKbK0LXGq4UIHCfM2W8WVoz/l0QO+JrGrqC3gg8qGyHP3NsVZKVAqG6cGmBi9WEs688U5B0NNGPXPLKE1ZXzHbSd6Pdub1xWv/BEo4RsAu1NySQJpcq3hqo9nLMsza9aiwKH5rG1aMUDu50LNtGs3vCx8ZAkcZpYVp1ZLeoD3pnZVc7siq3kiqJ7zDQoE3FORgD6PuAc6YB2PXW6I3ubw4hkvFMnkIK4/Cc/AEB8RYar6rjmgPVYXSm+ok39sPi9ppIE23k4LkFzz3dUbTM2ub1kKPCUoJLp2E4tUg4hqRidaC7rNxkPyI3lyBWrS8JD457pFYlTWYsUtU1P2sHhxKZuKdeDPQ/Jvo0y+xO5rK9OgmKCg0qxuwaXf4NYu6laqaGEQywRmRyhT1f3E0pQZ371dObo4FOdiVEODhvadPf0FCHjOtuaxWwEkFwyFHVtc0lVNhcy0rg65j2efHpDUXqQnqFBgc2PG23BVI1gY0JIDT5zp33wdFX3r6MjYxSUV7KbRBDwCD0Q3a9NepX9bqv3wpi1qYJ6kcht0iMAE+5WmHHeHWza2HFMXcUApSAU6cu2fzOfK+4gRMJPjNAdk/nVQT1UnWy9k+s6jvwaXBPI10ewaTz5ayRTXyku36N1xLsM6DnBPoJCunuDEXMI5dILgr3BVSCqvzboWsRW04bAfFbpYANioQgdDD5zerygHa61V7ICyD/x5G4li6VLIefsCGGBo+7fU149zYkHv7ruH8F/J26b11UH+gpThimLgenJectT3MnksMFaz8LiSRn6jnz7CMeXssxBoYRT0gvq4MN6JxFGD01HfcqfVuBkWXk8Mo1OE75v3HWovrJOrTXhYbr+JaPppA=="
        let password = "testpassword"
        let expectedDectyptedPayload = "{\n\t\"guid\" : \"6253e902-ce79-4027-bdc4-af51ed970eb5\",\n\t\"sharedKey\" : \"f9af4f4f-9587-4a11-9ccc-51f0215c8662\",\n\t\"options\" : {\"pbkdf2_iterations\":5000,\"fee_policy\":0,\"html5_notifications\":false,\"logout_time\":600000,\"tx_display\":0,\"always_keep_local_backup\":false,\"transactions_per_page\":30,\"additional_seeds\":[]},\n\t\"keys\" : [\n{\"addr\":\"1MKoTk9rPKCiYunb7i5URRsXCFCpc9wh3U\",\"priv\":\"8NMD7QNHv8Rg3gqonZHNDzJxostHP9TBmw6T2mWpcvbP\",\"created_time\":1424375705407,\"created_device_name\":\"javascript_web\",\"created_device_version\":\"1.0\"},\n{\"addr\":\"1AeLHuqqy69115XHpKbmxzfaxJQ3mcZCsS\",\"priv\":\"28TJYi8hitu57271yoNHvG5Z2Qyq2iSmg9EpaA2ouydK\",\"created_time\":0,\"created_device_name\":\"javascript_iphone_app\",\"created_device_version\":\"3.0\"}\n\t]\n}"

        let decryptedPayload = try subject
            .decryptWallet(
                encryptedWalletData: data,
                password: password
            )
            .get()

        XCTAssertEqual(decryptedPayload, expectedDectyptedPayload)
    }

    func test_encryptDecryptDataWithPassword() throws {
        let message = "155 is a bad number"
        let password = "1714"
        let iterations: UInt32 = 11
        let encrypted = try subject
            .encrypt(
                data: message,
                with: password,
                pbkdf2Iterations: iterations
            )
            .get()
        let decrypted = try subject
            .decrypt(
                data: encrypted,
                with: password,
                pbkdf2Iterations: iterations
            )
            .get()
        XCTAssertEqual(message, decrypted)
    }
}
