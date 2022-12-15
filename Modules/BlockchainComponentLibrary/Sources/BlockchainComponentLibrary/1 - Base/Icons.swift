// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// An icon asset view from the Component Library
///
/// See extension below for supported icons.
/// Note that coloring the icon is done via `.color(...)` instead of `.foregroundColor(...)`
/// Apply a fixed width or height to size the icon.
///
/// # Usage:
///
/// ```
/// Icon.activity
///     .color(.green)
///     .frame(width: 20)
/// ```
///
/// # Figma
///
///  [Assets - Icons](https://www.figma.com/file/3jESURhHQ4VBTQcu0aZkoX/01---Assets-%7C-Icons)
public struct Icon: View, Hashable, Codable {

    public let name: String

    fileprivate var renderingMode: Image.TemplateRenderingMode
    fileprivate var isCircle: Bool
    fileprivate var color: Color?
    fileprivate var circleColor: Color?

    private var size: Size?

    init(
        name: String,
        renderingMode: Image.TemplateRenderingMode = .template,
        isCircle: Bool = false,
        color: Color? = nil,
        circleColor: Color? = nil
    ) {
        self.name = name
        self.renderingMode = renderingMode
        self.isCircle = isCircle
        self.color = color
        self.circleColor = circleColor
    }

    public var body: some View {
        if let size {
            Content(icon: self).frame(width: size.width, height: size.height)
        } else {
            Content(icon: self)
        }
    }

    struct Content: View {

        let icon: Icon
        @Environment(\.iconColor) var iconColor

        var foregroundColor: Color {
            icon.color ?? iconColor ?? .accentColor
        }

        var backgroundColor: Color {
            icon.circleColor ?? iconColor?.opacity(0.15) ?? .accentColor.opacity(0.15)
        }

        var body: some View {
            if icon.isCircle {
                Circle()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(backgroundColor)
                    .inscribed(aspectRatio: 4 / 3, _content)
            } else {
                _content
            }
        }

        private var _content: some View {
            #if canImport(UIKit)
            ImageViewRepresentable(image: icon.uiImage, renderingMode: icon.renderingMode, tintColor: foregroundColor)
                .scaledToFit()
            #else
            icon.image
            #endif
        }
    }

    #if canImport(UIKit)
    public var uiImage: UIImage? {
        UIImage(
            named: name,
            in: .componentLibrary,
            with: nil
        )
    }
    #endif

    public var image: some View {
        Image(name, bundle: .componentLibrary)
            .renderingMode(renderingMode)
            .resizable()
            .scaledToFit()
    }

    enum Key: String, CodingKey {
        case name, circle, foreground, background
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.isCircle = (try? container.decodeIfPresent(Bool.self, forKey: .circle)) ?? false
        self.renderingMode = .template
        self.color = try container.decodeIfPresent(Texture.Color.self, forKey: .foreground)?.swiftUI ?? .semantic.muted
        self.circleColor = try container.decodeIfPresent(Texture.Color.self, forKey: .background)?.swiftUI ?? color?.opacity(0.15)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(name, forKey: .name)
        try container.encode(isCircle, forKey: .circle)
        try container.encodeIfPresent(color?.texture.color, forKey: .foreground)
        try container.encodeIfPresent(circleColor?.texture.color, forKey: .background)
    }
}

extension EnvironmentValues {

    public var iconColor: Color? {
        get { self[IconColorEnvironmentValue.self] }
        set { self[IconColorEnvironmentValue.self] = newValue }
    }
}

private struct IconColorEnvironmentValue: EnvironmentKey {
    static var defaultValue: Color?
}

extension View {

    @warn_unqualified_access public func iconColor(_ color: Color?) -> some View {
        environment(\.iconColor, color)
    }
}

extension Icon {

    public func color(_ color: Color) -> Icon {
        var newIcon = self
        newIcon.color = color
        newIcon.circleColor = color.opacity(0.15)
        return newIcon
    }

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode) -> Icon {
        var newIcon = self
        newIcon.renderingMode = renderingMode
        return newIcon
    }

    public func circle(backgroundColor: Color? = nil) -> Icon {
        var newIcon = self
        newIcon.isCircle = true
        newIcon.circleColor = backgroundColor
        return newIcon
    }

    public func micro() -> Icon {
        var icon = self
        icon.size = .init(length: 16.pt)
        return icon
    }

    public func small() -> Icon {
        var icon = self
        icon.size = .init(length: 24.pt)
        return icon
    }

    public func medium() -> Icon {
        var icon = self
        icon.size = .init(length: 36.pt)
        return icon
    }

    public func large() -> Icon {
        var icon = self
        icon.size = .init(length: 72.pt)
        return icon
    }

    public func scaleToFit() -> Icon {
        var icon = self
        icon.size = nil
        return icon
    }
}

// swiftformat:disable redundantBackticks

extension Icon {
    public static let `activity` = Icon(name: "Activity")
    public static let `airdrop` = Icon(name: "Airdrop")
    public static let `alert` = Icon(name: "Alert")
    public static let `android` = Icon(name: "Android")
    public static let `apple` = Icon(name: "Apple")
    public static let `arrowRight` = Icon(name: "Arrow Right")
    public static let `arrowDown` = Icon(name: "Arrow-Down")
    public static let `arrowUp` = Icon(name: "Arrow-Up")
    public static let `backspaceAndroid` = Icon(name: "Backspace Android")
    public static let `backup` = Icon(name: "Backup")
    public static let `bank` = Icon(name: "Bank")
    public static let `blockchain` = Icon(name: "Blockchain")
    public static let `cash` = Icon(name: "Cash")
    public static let `calendar` = Icon(name: "Calendar")
    public static let `call` = Icon(name: "Call")
    public static let `camera` = Icon(name: "Camera")
    public static let `cart` = Icon(name: "Cart")
    public static let `chartBar` = Icon(name: "Chart Bar")
    public static let `chartBubble` = Icon(name: "Chart Bubble")
    public static let `chartPie` = Icon(name: "Chart Pie")
    public static let `chat` = Icon(name: "Chat")
    public static let `checkCircle` = Icon(name: "Check Circle")
    public static let `check` = Icon(name: "Check")
    public static let `chevronDown` = Icon(name: "Chevron-Down")
    public static let `chevronLeft` = Icon(name: "Chevron-Left")
    public static let `chevronRight` = Icon(name: "Chevron-Right")
    public static let `chevronUp` = Icon(name: "Chevron-Up")
    public static let `clipboard` = Icon(name: "Clipboard")
    public static let `closeCirclev2` = Icon(name: "Close Circle v2", renderingMode: .original)
    public static let `closeCirclev3` = Icon(name: "Close Circle v3", renderingMode: .original)
    public static let `closeCircle` = Icon(name: "Close Circle")
    public static let `closev2` = Icon(name: "Close v2")
    public static let `close` = Icon(name: "Close")
    public static let `colorPicker` = Icon(name: "Color Picker")
    public static let `components` = Icon(name: "Components")
    public static let `computer` = Icon(name: "Computer")
    public static let `copy` = Icon(name: "Copy")
    public static let `creditcard` = Icon(name: "Creditcard")
    public static let `delete` = Icon(name: "Delete")
    public static let `deposit` = Icon(name: "Deposit")
    public static let `download` = Icon(name: "Download")
    public static let `edit` = Icon(name: "Edit")
    public static let `education` = Icon(name: "Education")
    public static let `email` = Icon(name: "Email")
    public static let `error` = Icon(name: "Error")
    public static let `exchange` = Icon(name: "Exchange")
    public static let `expandLess` = Icon(name: "Expand Less")
    public static let `expandMore` = Icon(name: "Expand More")
    public static let `explore` = Icon(name: "Explore")
    public static let `faceID` = Icon(name: "Face ID")
    public static let `favorite` = Icon(name: "Favorite")
    public static let `favoriteEmpty` = Icon(name: "Favorite Empty")
    public static let `filter` = Icon(name: "Filter")
    public static let `fingerprint` = Icon(name: "Fingerprint")
    public static let `flag` = Icon(name: "Flag")
    public static let `flashOff` = Icon(name: "Flash Off")
    public static let `flashOn` = Icon(name: "Flash On")
    public static let `fullscreenExit` = Icon(name: "Fullscreen Exit")
    public static let `fullscreen` = Icon(name: "Fullscreen")
    public static let `globe` = Icon(name: "Globe")
    public static let `googleTranslate` = Icon(name: "Google Translate")
    public static let `hardware` = Icon(name: "Hardware")
    public static let `history` = Icon(name: "History")
    public static let `home` = Icon(name: "Home")
    public static let `identification` = Icon(name: "Identification")
    public static let `information` = Icon(name: "Information")
    public static let `interestCircle` = Icon(name: "Interest Circle")
    public static let `interest` = Icon(name: "Interest")
    public static let `key` = Icon(name: "Key")
    public static let `keyboard` = Icon(name: "Keyboard")
    public static let `laptop` = Icon(name: "Laptop")
    public static let `legal` = Icon(name: "Legal")
    public static let `lineChartUp` = Icon(name: "Line Chart Up")
    public static let `link` = Icon(name: "Link")
    public static let `listBullets` = Icon(name: "List Bullets")
    public static let `lockClosed` = Icon(name: "Lock Closed")
    public static let `lockOpen` = Icon(name: "Lock Open")
    public static let `logout` = Icon(name: "Logout")
    public static let `marketUp` = Icon(name: "Market Up")
    public static let `menu` = Icon(name: "Menu")
    public static let `microphone` = Icon(name: "Microphone")
    public static let `minusCircle` = Icon(name: "Minus Circle")
    public static let `moneyUSD` = Icon(name: "Money USD")
    public static let `moreHorizontal` = Icon(name: "More Horizontal")
    public static let `moreVertical` = Icon(name: "More Vertical")
    public static let `newWindow` = Icon(name: "New Window")
    public static let `notificationOff` = Icon(name: "Notification Off")
    public static let `notificationOn` = Icon(name: "Notification On")
    public static let `paperclip` = Icon(name: "Paperclip")
    public static let `pending` = Icon(name: "Pending")
    public static let `people` = Icon(name: "People")
    public static let `phone` = Icon(name: "Phone")
    public static let `placeholder` = Icon(name: "Placeholder")
    public static let `playCircle` = Icon(name: "Play Circle")
    public static let `plusCircle` = Icon(name: "Plus Circle")
    public static let `plus` = Icon(name: "Plus")
    public static let `portfolio` = Icon(name: "Portfolio")
    public static let `present` = Icon(name: "Present")
    public static let `print` = Icon(name: "Print")
    public static let `private` = Icon(name: "Private")
    public static let `qrCode` = Icon(name: "QR Code")
    public static let `giftbox` = Icon(name: "Giftbox")
    public static let `giftboxHighlighted` = Icon(name: "Giftbox Highlighted")
    public static let `questionCircle` = Icon(name: "Question Circle")
    public static let `question` = Icon(name: "Question")
    public static let `receive` = Icon(name: "Receive")
    public static let `refresh` = Icon(name: "Refresh")
    public static let `repeat` = Icon(name: "Repeat")
    public static let `search` = Icon(name: "Search")
    public static let `sell` = Icon(name: "Sell")
    public static let `send` = Icon(name: "Send")
    public static let `settings` = Icon(name: "Settings")
    public static let `shareAndroid` = Icon(name: "Share Android")
    public static let `shareiOS` = Icon(name: "Share iOS")
    public static let `shield` = Icon(name: "Shield")
    public static let `signout` = Icon(name: "Signout")
    public static let `subdirectory` = Icon(name: "Subdirectory")
    public static let `support` = Icon(name: "Support")
    public static let `swap` = Icon(name: "Swap")
    public static let `sync` = Icon(name: "Sync")
    public static let `tag` = Icon(name: "Tag")
    public static let `timeout` = Icon(name: "Timeout")
    public static let `tor` = Icon(name: "Tor")
    public static let `trade` = Icon(name: "Trade")
    public static let `unfoldLess` = Icon(name: "Unfold Less")
    public static let `unfoldMore` = Icon(name: "Unfold More")
    public static let `userAdd` = Icon(name: "User Add")
    public static let `user` = Icon(name: "User")
    public static let `userv2` = Icon(name: "User-v2")
    public static let `userv2Filled` = Icon(name: "User-v2 filled")
    public static let `verified` = Icon(name: "Verified")
    public static let `viewfinder` = Icon(name: "Viewfinder")
    public static let `visibilityOff` = Icon(name: "Visibility Off")
    public static let `visibilityOn` = Icon(name: "Visibility On")
    public static let `wallet` = Icon(name: "Wallet")
    public static let `withdraw` = Icon(name: "Withdraw")
}

extension Icon {
    public static let `walletBuy` = Icon(name: "Wallet Buy")
    public static let `walletDeposit` = Icon(name: "Wallet Deposit")
    public static let `walletExchange` = Icon(name: "Wallet Exchange")
    public static let `walletInterest` = Icon(name: "Wallet Interest")
    public static let `walletPending` = Icon(name: "Wallet Pending")
    public static let `walletPercent` = Icon(name: "Wallet Percent")
    public static let `walletPrivate` = Icon(name: "Wallet Private")
    public static let `walletReceive` = Icon(name: "Wallet Receive")
    public static let `walletRepeat` = Icon(name: "Wallet Repeat")
    public static let `walletSell` = Icon(name: "Wallet Sell")
    public static let `walletSend` = Icon(name: "Wallet Send")
    public static let `walletSwap` = Icon(name: "Wallet Swap")
    public static let `walletTrade` = Icon(name: "Wallet Trade")
    public static let `walletTransfer` = Icon(name: "Wallet Transfer")
    public static let `walletWithdraw` = Icon(name: "Wallet Withdraw")
    public static let `walletStaking` = Icon(name: "Wallet Staking Circle")
}

extension Icon {
    public static let `superAppHome` = Icon(name: "SuperApp Home")
    public static let `superAppHomeFilled` = Icon(name: "SuperApp Home Filled")
    public static let `superAppPrices` = Icon(name: "SuperApp Prices")
    public static let `superAppPricesFilled` = Icon(name: "SuperApp Prices Filled")
    public static let `superAppNft` = Icon(name: "NFT")
    public static let `superAppNftFilled` = Icon(name: "NFT Filled")
    public static let `superAppCard` = Icon(name: "SuperApp Card")
    public static let `superAppCardFilled` = Icon(name: "SuperApp Card Filled")
    public static let `superAppFilterFilled` = Icon(name: "SuperApp Filter Filled")
    public static let `superAppFilter` = Icon(name: "SuperApp Filter")
}

extension Icon {
    public static let allIcons: [Icon] = [
        .activity,
        .airdrop,
        .alert,
        .android,
        .apple,
        .arrowDown,
        .arrowRight,
        .arrowUp,
        .backspaceAndroid,
        .backup,
        .bank,
        .blockchain,
        .calendar,
        .call,
        .camera,
        .cart,
        .chartBar,
        .chartBubble,
        .chartPie,
        .chat,
        .check,
        .checkCircle,
        .chevronDown,
        .chevronLeft,
        .chevronRight,
        .chevronUp,
        .clipboard,
        .close,
        .closeCircle,
        .closeCirclev2,
        .closeCirclev3,
        .closev2,
        .colorPicker,
        .components,
        .computer,
        .copy,
        .creditcard,
        .delete,
        .deposit,
        .download,
        .edit,
        .education,
        .email,
        .error,
        .exchange,
        .expandLess,
        .expandMore,
        .explore,
        .faceID,
        .favorite,
        .filter,
        .fingerprint,
        .flag,
        .flashOff,
        .flashOn,
        .fullscreen,
        .fullscreenExit,
        .globe,
        .googleTranslate,
        .hardware,
        .history,
        .home,
        .identification,
        .information,
        .interest,
        .interestCircle,
        .key,
        .keyboard,
        .laptop,
        .legal,
        .lineChartUp,
        .link,
        .listBullets,
        .lockClosed,
        .lockOpen,
        .logout,
        .marketUp,
        .menu,
        .microphone,
        .minusCircle,
        .moneyUSD,
        .moreHorizontal,
        .moreVertical,
        .newWindow,
        .notificationOff,
        .notificationOn,
        .paperclip,
        .pending,
        .people,
        .phone,
        .placeholder,
        .playCircle,
        .plus,
        .plusCircle,
        .portfolio,
        .present,
        .print,
        .private,
        .qrCode,
        .question,
        .questionCircle,
        .receive,
        .refresh,
        .repeat,
        .search,
        .sell,
        .send,
        .settings,
        .shareAndroid,
        .shareiOS,
        .shield,
        .signout,
        .subdirectory,
        .support,
        .swap,
        .sync,
        .tag,
        .timeout,
        .tor,
        .trade,
        .unfoldLess,
        .unfoldMore,
        .user,
        .userAdd,
        .verified,
        .visibilityOff,
        .visibilityOn,
        .wallet,
        .walletBuy,
        .walletDeposit,
        .walletExchange,
        .walletInterest,
        .walletPending,
        .walletPercent,
        .walletPrivate,
        .walletReceive,
        .walletRepeat,
        .walletSell,
        .walletSend,
        .walletSwap,
        .walletTrade,
        .walletTransfer,
        .walletWithdraw,
        .withdraw
    ]
}

#if canImport(UIKit)
/// SwiftUI's `Image` does not correctly scale up vector images. Images end up extremely blurry.
/// So, we get around this by reverting back to `UIImageView` to display icons.
struct ImageViewRepresentable: UIViewRepresentable {
    let image: UIImage?
    let renderingMode: Image.TemplateRenderingMode
    let tintColor: Color

    private var uiRenderingMode: UIImage.RenderingMode {
        switch renderingMode {
        case .original:
            return .alwaysOriginal
        case .template:
            return .alwaysTemplate
        @unknown default:
            return .alwaysOriginal
        }
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIImageView(
            image: image?.withRenderingMode(uiRenderingMode)
        )
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.tintColor = UIColor(tintColor)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Do nothing
    }
}
#endif

struct Icon_Previews: PreviewProvider {
    static let columns = Array(
        repeating: GridItem(.fixed(110)),
        count: 3
    )

    static var previews: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 48) {
            ForEach(Icon.allIcons, id: \.name) { icon in
                VStack {
                    icon
                        .color(.semantic.muted)
                        .frame(width: 24)

                    icon.circle()
                        .color(.semantic.muted)
                        .frame(width: 32)

                    Text(icon.name)
                        .typography(.micro)
                }
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .previewLayout(.sizeThatFits)
    }
}
