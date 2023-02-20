// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

final class StringTests: XCTestCase {

    func testHasHex() throws {
        let pairs: [(testcase: String, result: Bool)] = [
            //
            ("0x0x", true),
            ("0x", true),
            ("0x1", true),
            ("0xa", true),

            //
            (" 0x", false),
            ("00x", false),
            ("a0x1", false),
            ("a0xa", false)
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.hasHexPrefix, pair.result)
        }
    }

    func testBase64() {
        let original = Data("The quick brown fox jumps over 13 lazy dogs.".utf8)
        XCTAssertEqual(original.base64EncodedString(), "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIDEzIGxhenkgZG9ncy4=")
        XCTAssertEqual(Data(base64Encoded: original.base64EncodedString()), original)
    }

    func testBase64URL() {
        let original = Data("The quick brown fox jumps over 13 lazy dogs.".utf8)
        XCTAssertEqual(
            original.base64EncodedString().base64URLEscaped,
            "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIDEzIGxhenkgZG9ncy4"
        )
        XCTAssertEqual(
            Data(base64Encoded: original.base64EncodedString().base64URLEscaped.base64URLUnescaped),
            original
        )
    }

    func testBase64URLEscaping() {
        do {
            let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x98, 0x99, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9])
            XCTAssertEqual(data.base64EncodedString(), "AAECAwQFBgcICRAREhMUFRYXGBkgISIjJCUmJygpMDEyMzQ1Njc4OUBBQkNERUZHSElQUVJTVFVWV1hZYGFiY2RlZmdoaXBxcnN0dXZ3eHmAgYKDhIWGh4iJkJGSk5SVmJmgoaKjpKWmp6ipsLGys7S1tre4ucDBwsPExcbHyMnQ0dLT1NXW19jZ8PHy8/T19vf4+Q==")
            XCTAssertEqual(data.base64EncodedString().base64URLEscaped, "AAECAwQFBgcICRAREhMUFRYXGBkgISIjJCUmJygpMDEyMzQ1Njc4OUBBQkNERUZHSElQUVJTVFVWV1hZYGFiY2RlZmdoaXBxcnN0dXZ3eHmAgYKDhIWGh4iJkJGSk5SVmJmgoaKjpKWmp6ipsLGys7S1tre4ucDBwsPExcbHyMnQ0dLT1NXW19jZ8PHy8_T19vf4-Q")
            XCTAssertEqual(data.base64EncodedString(), data.base64EncodedString().base64URLEscaped.base64URLUnescaped)
            XCTAssertEqual(
                Data(data.base64EncodedString().utf8),
                Data(data.base64EncodedString().base64URLEscaped.base64URLUnescaped.utf8)
            )
        }
        do {
            let data = Data([0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x98, 0x99, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9])
            XCTAssertEqual(data.base64EncodedString(), "AgMEBQYHCAkQERITFBUWFxgZICEiIyQlJicoKTAxMjM0NTY3ODlAQUJDREVGR0hJUFFSU1RVVldYWWBhYmNkZWZnaGlwcXJzdHV2d3h5gIGCg4SFhoeIiZCRkpOUlZiZoKGio6SlpqeoqbCxsrO0tba3uLnAwcLDxMXGx8jJ0NHS09TV1tfY2fDx8vP09fb3+Pk=")
            XCTAssertEqual(data.base64EncodedString().base64URLEscaped, "AgMEBQYHCAkQERITFBUWFxgZICEiIyQlJicoKTAxMjM0NTY3ODlAQUJDREVGR0hJUFFSU1RVVldYWWBhYmNkZWZnaGlwcXJzdHV2d3h5gIGCg4SFhoeIiZCRkpOUlZiZoKGio6SlpqeoqbCxsrO0tba3uLnAwcLDxMXGx8jJ0NHS09TV1tfY2fDx8vP09fb3-Pk")
            XCTAssertEqual(data.base64EncodedString(), data.base64EncodedString().base64URLEscaped.base64URLUnescaped)
            XCTAssertEqual(
                Data(data.base64EncodedString().utf8),
                Data(data.base64EncodedString().base64URLEscaped.base64URLUnescaped.utf8)
            )
        }
    }

    func testWithHex() throws {
        let pairs: [(testcase: String, result: String)] = [
            //
            ("0x", "0x"),
            ("0xa", "0xa"),
            ("0x1", "0x1"),

            //
            ("", "0x"),
            (" ", "0x "),
            (" 0x", "0x 0x"),
            ("a", "0xa"),
            ("1", "0x1"),
            ("x", "0xx"),
            ("0", "0x0")
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.withHex, pair.result)
        }
    }

    func testWithoutHex() throws {
        let pairs: [(testcase: String, result: String)] = [
            //
            ("0x", ""),
            ("0xa", "a"),
            ("0x1", "1"),

            //
            ("", ""),
            (" ", " "),
            (" 0x", " 0x"),
            ("a", "a"),
            ("1", "1"),
            ("x", "x"),
            ("0", "0")
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.withoutHex, pair.result)
        }
    }

    func testIbanFormatting() throws {
        let iban = "EE707777000013197360"
        let formatted = iban.separatedWithSeparator(" ", stride: 4)
        XCTAssertEqual("EE70 7777 0000 1319 7360", formatted)
    }

    func testEmptyIban() throws {
        let iban = ""
        let formatted = iban.separatedWithSeparator(" ", stride: 4)
        XCTAssertEqual("", formatted)
    }

    func testContainsEmoji() {
        let all = "😂😇🙃😍😜😘🤓😎😏🥺😢🤯😱🤔😶😵🤐🤢🤧😷🤕🤑🤠😈🤡💩👻☠️👽👾🤖🎃💪💋💄👂👃👣👁️👀🧠👶👏🤝🙌👍👎✊✌️🤘👌👉👋✍️🙏💅🤳💃👕👖👗👙👘👠👢👞👟🎩🧢👒🎓👑💍👛💼🎒🥶🤬👅🤮🦶🥳🐶🐱🐭🐰🦊🐻🐼🐮🐨🐯🦁🐷🐽🐸🐵🙈🐔🐧🐣🦆🦅🦉🦇🐺🐗🐴🦄🐝🐛🦋🐌🐞🐜🕷️🕸️🦂🐢🐍🦎🦖🐊🦓🦍🦏🐙🦀🐬🐋🦈🐘🐪🐃🐑🐐🦌🦃🐀🐾🐉🌵🌲🌴🍀🎋🍁🍄🐚💐🌹🌸🌻🌕🌙⭐✨⚡☄️💥🔥🌪️🌈☀️☁️❄️⛄💨💦🌊🍎🍐🍊🍋🍌🍉🍇🍓🍈🍒🍑🍍🥝🍆🥑🥒🌶️🌽🥕🥔🥐🍞🧀🥚🍳🥞🥓🍗🌭🍔🍟🍕🥙🌮🌯🥗🍝🍜🍣🍱🍤🍚🍘🍥🍡🍦🎂🍭🍬🍫🍿🍩🍪🥜🌰🍯🥛🍼☕🍵🍶🍺🍷🥃🍸🍾🥄🍽️⚽🏀🏈⚾🎾🏐🎱🏓🏸🏒🏏🥅⛳🏹🎣🥊🥋🎽⛸️🎿🏆🎖️🎟️🎪🎭🎨🎬🎤🎧🎼🎹🥁🎷🎺🎸🎻🎲♟️🎯🎳🎮🎰🛹🧩🚗🏎️🚓🚑🚒🚚🚜🚲🛵🏍️🚨🚠🚂✈️💺🚀🛸🚁🛶⛵🚢⚓🚧🚦🗺️🗿🗽🗼🏰🏯🏟️🎡🎢🎠🏖️⛰️🏕️🏠🏭🏥🏦🏛️⛪🕌🕍🗾⌚📱💻🖨️🕹️💾📷🎥📟📺📻🎛️⏰⌛📡🔋🔌💡🔦🕯️🛢️💵💰💳💎⚖️🔧🔨🔩⚙️⛓️🔫💣🔪🗡️🛡️🚬⚰️🏺🔮📿💈🔭🔬🕳️💊💉🚽🚰🚿🛋️🔑🚪🗄️📎📏📐📌✂️🗑️🖼️🛍️🛒🎁🎈🎏🎀🎉🎎🏮🎐✉️📦📜📈🗞️📓📖🖍️✏️🔒🧲🧹❤️💔✝️☪️🕉️☸️✡️🕎☯️☦️♈♊♋♌♍♎♏♐♑♒♓🆔♾️⚛️☢️🆚🆘🚫🚭💯❗❓⚠️🔱⚜️♻️🏧🆒🆕🆓🆙🎵➕💱🔔♠️♣️🃏🀄🏁🔊▶️🔛💤"
        let uniq = all.unique.map(String.init)
        // Sanity test, check unit test is not breaking unicode logic when splitting string to individual strings.
        XCTAssertEqual(all, uniq.joined())
        for emoji in uniq {
            XCTAssertTrue(emoji.containsEmoji, "\(emoji) not recognised as emoji")
        }
    }
}
