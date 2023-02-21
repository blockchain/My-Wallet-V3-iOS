@testable import BlockchainNamespace
import XCTest

// swiftlint:disable single_test_class

final class TagTestSchemaTests: XCTestCase {

    // swiftlint:disable force_try
    let language = try! Language.root(of: .test).language

    func test_children() throws {

        let schema = try language["blockchain.test.schema"].unwrap()
        XCTAssertEqual(schema.children.keys.set, ["boolean", "string", "stored", "stored_boolean"].set)

        let boolean = try language["blockchain.test.schema.boolean"].unwrap()
        XCTAssertEqual(boolean.children.keys.set, [].set)
    }

    func test_type() throws {
        let schema = try language["blockchain.test.schema"].unwrap()
        XCTAssertEqual(schema.type.keys.set, ["blockchain.test.schema"].set)

        let boolean = try language["blockchain.test.schema.boolean"].unwrap()
        XCTAssertEqual(boolean.type.keys.set, ["blockchain.test.schema.boolean", "blockchain.type.boolean"].set)
    }

    func test_lineage() throws {
        let boolean = try language["blockchain.test.schema.boolean"].unwrap()
        XCTAssertEqual(
            Array(boolean.lineage).map(\.id),
            ["blockchain.test.schema.boolean", "blockchain.test.schema", "blockchain.test", "blockchain"]
        )
    }

    func test_descendant() throws {
        let test = try language["blockchain.test"].unwrap()
        XCTAssertNotNil(test["schema", "boolean"])
    }

    func test_name() throws {
        let boolean = try language["blockchain.test.schema.boolean"].unwrap()
        XCTAssertEqual(boolean.name, "boolean")
    }

    func test_id() throws {
        let boolean = try language["blockchain.test.schema.boolean"].unwrap()
        XCTAssertEqual(boolean.id, "blockchain.test.schema.boolean")
    }
}

final class TagBlockchainSchemaTests: XCTestCase {

    func test_children() throws {
        XCTAssertEqual(blockchain.user.email[].children.keys.set, ["address", "is"].set)
        XCTAssertEqual(blockchain.user.email.address[].children.keys.set, [].set)
        XCTAssertEqual(blockchain.user.email.is.verified[].children.keys.set, [].set)
    }

    func test_type() throws {
        XCTAssertEqual(blockchain.user.email[].type.keys.set, ["blockchain.user.email"].set)
        XCTAssertEqual(
            blockchain.user.email.address[].type.keys.set,
            ["blockchain.user.email.address", "blockchain.db.type.string", "blockchain.db.leaf"].set
        )
    }

    func test_equal() throws {
        let tag1 = blockchain.user.email.address
        let tag2 = blockchain.user.email.address
        let tag3 = blockchain.user.currency
        XCTAssertTrue(tag1[] == tag2)
        XCTAssertFalse(tag1[] == tag3)
    }

    func test_lineage() throws {
        XCTAssertEqual(
            Array(blockchain.user.email.address[].lineage).map(\.id),
            ["blockchain.user.email.address", "blockchain.user.email", "blockchain.user", "blockchain"]
        )
    }

    func test_descendant() throws {
        let user = blockchain.user[]
        XCTAssertNotNil(user["email", "address"])
    }

    func test_name() throws {
        XCTAssertEqual(blockchain.user.email.address[].name, "address")
    }

    func test_id() throws {
        XCTAssertEqual(blockchain.user.email.address[].id, "blockchain.user.email.address")
    }

    func test_is() throws {
        XCTAssertTrue(blockchain.user.email.address[].is(blockchain.db.type.string))
        XCTAssertTrue(blockchain.user.id[].is(blockchain.db.type.string))
        XCTAssertTrue(blockchain.user.id[].is(blockchain.db.collection.id))
        XCTAssertTrue(blockchain.ux.error.then.launch.url[].is(blockchain.ui.type.action.then.launch.url))
    }

    func test_isNot() throws {
        XCTAssertTrue(blockchain.session.state.preference.value[].isNot(blockchain.session.state.shared.value))
        XCTAssertTrue(blockchain.user.email.address[].isNot(blockchain.db.type.boolean))
    }

    func test_pattern_match() throws {
        switch blockchain.user.email.address[] {
        case blockchain.db.type.string:
            break
        default:
            XCTFail("Expected 'blockchain.db.type.string'")
        }
    }

    func test_isAncestor() throws {
        XCTAssertTrue(blockchain.user[].isAncestor(of: blockchain.user.email.address[]))
    }

    func test_isDescendant() throws {
        XCTAssertTrue(blockchain.user.email.address[].isDescendant(of: blockchain.user[]))
    }

    func test_static_key_indices() throws {
        let id = blockchain.user["abcdef"].account
        let key = id.key()
        XCTAssertEqual(key.indices, [blockchain.user.id[]: "abcdef"])
    }

    func test_static_key_any_context() throws {
        let id = blockchain.ux.asset["BTC"].account["Trading"].buy[6000]
        let key = id.key()
        XCTAssertEqual(
            key.indices,
            [
                blockchain.ux.asset.id[]: "BTC",
                blockchain.ux.asset.account.id[]: "Trading"
            ]
        )
        XCTAssertEqual(
            key.context,
            [
                blockchain.ux.asset.id: "BTC",
                blockchain.ux.asset.account.id: "Trading",
                blockchain.ux.asset.account.buy: 6000
            ]
        )
    }

    func test_protonym() throws {

        do {
            let tag = blockchain.ux.transaction.enter.amount.button.confirm.tap[]
            XCTAssertEqual(tag.id, "blockchain.ux.transaction.enter.amount.button.confirm.event.select")
        }

        do {
            let tag = try AnyDecoder().decode(Tag.self, from: "blockchain.ux.transaction.enter.amount.button.confirm.tap")
            XCTAssertEqual(tag.id, "blockchain.ux.transaction.enter.amount.button.confirm.event.select")
        }

        do {
            let ref = try AnyDecoder().decode(Tag.Reference.self, from: "blockchain.ux.transaction.enter.amount.button.confirm.tap")
            XCTAssertEqual(ref.tag.id, "blockchain.ux.transaction.enter.amount.button.confirm.event.select")
        }
    }

    func test_privacy_policy() throws {

        do {
            let context: Tag.Context = [
                blockchain.ux.type.analytics.privacy.policy.obfuscate: "obfuscate",
                blockchain.ux.type.analytics.privacy.policy.exclude: "exclude",
                blockchain.ux.type.analytics.privacy.policy.include: "include"
            ]

            XCTAssertEqual(context.sanitised(), [
                blockchain.ux.type.analytics.privacy.policy.obfuscate: "******",
                blockchain.ux.type.analytics.privacy.policy.include: "include"
            ])
        }

        do {

            // blockchain.ux.asset.account -> blockchain.ux.type.analytics.privacy.policy.obfuscate

            XCTAssertTrue(blockchain.ux.asset.account[].privacyPolicy.is(blockchain.ux.type.analytics.privacy.policy.obfuscate))
            XCTAssertTrue(blockchain.ux.asset.account.id[].privacyPolicy.is(blockchain.ux.type.analytics.privacy.policy.obfuscate))
            XCTAssertTrue(blockchain.ux.asset.account.rewards.deposit[].privacyPolicy.is(blockchain.ux.type.analytics.privacy.policy.obfuscate))

            let context: Tag.Context = [
                blockchain.ux.asset.account.id: "children are obfuscated",
                blockchain.ux.asset.account.rewards.deposit: "children are obfuscated"
            ]

            XCTAssertEqual(
                context.sanitised(), [
                    blockchain.ux.asset.account.id: "******",
                    blockchain.ux.asset.account.rewards.deposit: "******"
                ]
            )
        }
    }

    func test_json() throws {

        var json = TaggedJSON(
            ["article": ["plain": ["navigation": ["bar": ["button": ["close": ["title": ["text": "close"]]]]]]]],
            as: blockchain.ux.type.story
        )

        XCTAssertEqual(json.article.plain.navigation.bar.button.close.title.text, "close")

        json.article.plain.navigation.bar.button.close.title.text = "x"
        json.article.plain.navigation.bar.button.close.tap.then.close = true

        XCTAssertEqual(json.article.plain.navigation.bar.button.close.title.text, "x")
        try XCTAssertTrue(json.article.plain.navigation.bar.button.close.tap.then.close.unwrap())

        json.article.plain.navigation.bar.button.back.tap.policy.discard.if = false

        try XCTAssertFalse(json.article.plain.navigation.bar.button.back.tap.policy.discard.if.unwrap())

        do {
            let any: Any = ["article": ["plain": ["navigation": ["bar": ["button": ["close": ["title": ["text": "decoded"]]]]]]]]
            let decoded = try AnyDecoder().decode(L_blockchain_ux_type_story.JSON.self, from: any)
            XCTAssertEqual(decoded.article.plain.navigation.bar.button.close.title.text, "decoded")
        }
    }

    func test_json_2() throws {

        struct Money: Codable {
            let amount: String
            let currency: String
        }

        var preview = L_blockchain_user_earn_product_asset.JSON(.empty)

        preview.rates.rate = 0.055
        preview.account.balance[] = Money(amount: "1", currency: "ETH")
        preview.account.bonding.deposits[] = Money(amount: "2", currency: "ETH")
        preview.account.locked[] = Money(amount: "3", currency: "ETH")
        preview.account.total.rewards[] = Money(amount: "4", currency: "ETH")
        preview.account.unbonding.withdrawals[] = Money(amount: "5", currency: "ETH")
        preview.limit.days.bonding = 5
        preview.limit.days.unbonding = 0
        preview.limit.withdraw.is.disabled = true
        preview.limit.reward.frequency = blockchain.user.earn.product.asset.limit.reward.frequency.daily[]
        preview.activity = []
    }

    func test_tag_last_declared_descendant() throws {

        typealias ƒ = (AnyJSON, Tag.DeclaredDescendantMultipleOptionsPolicy) throws -> Tag

        let action = blockchain.ui.type.action
        let lastDeclaredDescendant: ƒ = action.then[].lastDeclaredDescendant

        do {
            let data: AnyJSON = [
                "navigate": ["to": "blockchain.ux.asset[BTC]"]
            ]
            try XCTAssertEqual(lastDeclaredDescendant(data, .any), action.then.navigate.to[])
        }

        do {
            let data: AnyJSON = [
                "not in manifest": [:],
                "navigate": ["to": "blockchain.ux.asset[BTC]"]
            ]
            try XCTAssertEqual(lastDeclaredDescendant(data, .any), action.then.navigate.to[])
        }

        do {
            let data: AnyJSON = [
                "set": ["session": ["state": [["key": "blockchain.app.dynamic[test].session.state.value", "value": true]]]]
            ]
            try XCTAssertEqual(lastDeclaredDescendant(data, .any), action.then.set.session.state[])
        }

        do {
            let data: AnyJSON = [
                "enter": ["into": "blockchain.ux.asset[BTC]"],
                "navigate": ["to": "blockchain.ux.asset[BTC]"]
            ]
            XCTAssertThrowsError(try lastDeclaredDescendant(data, .throws))
            XCTAssertThrowsError(try lastDeclaredDescendant(data, .priority { _, _ in throw "Test" }))
            XCTAssertEqual(try lastDeclaredDescendant(data, .priority { tag, children in
                let then = try tag.as(blockchain.ui.type.action.then)
                XCTAssertEqual(children, [then.navigate[], then.enter[]])
                return then.navigate[]
            }), action.then.navigate.to[])

        }
    }
}
