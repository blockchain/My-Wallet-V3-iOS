// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct CardTokenIdResponse: Decodable {
    public let cardTokenId: String
    public let vgsVaultId: String

    public init(cardTokenId: String, vgsVaultId: String) {
        self.cardTokenId = cardTokenId
        self.vgsVaultId = vgsVaultId
    }

    enum CodingKeys: String, CodingKey {
        case cardTokenId = "card_token_id"
        case vgsVaultId = "vgs_vault_id"
    }
}
