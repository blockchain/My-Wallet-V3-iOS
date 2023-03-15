import BlockchainUI
import SwiftUI

struct EarnLearningCardView: View {

    @BlockchainApp var app

    var learn: L & I_blockchain_ux_earn_discover_learn = blockchain.ux.earn.discover.learn

    let icon: Icon
    let title: String
    let message: String
    let backgroundColor: Color

    @State private var url: URL?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
            VStack(alignment: .leading, spacing: 8.pt) {
                HStack {
                    icon.color(.semantic.primary)
                        .frame(width: 20.pt, height: 20.pt)
                    Text(title)
                        .foregroundColor(.semantic.body)
                }
                .padding(.bottom, 4.pt)
                Text(message)
                    .lineLimit(nil)
                    .foregroundColor(.semantic.title)
                    .layoutPriority(1)
                    .minimumScaleFactor(0.9)
                Color.clear
                    .frame(maxWidth: .infinity)
                    .layoutPriority(0)
                SmallMinimalButton(title: L10n.learnMore) {
                    $app.post(event: learn.more.paragraph.button.small.minimal.tap)
                }
                .layoutPriority(1)
            }
            .padding(16.pt)
            .multilineTextAlignment(.leading)
        }
        .bindings {
            subscribe($url, to: learn.more.url)
        }
        .batch(.set(learn.more.paragraph.button.small.minimal.tap.then.launch.url, to: url))
        .typography(.paragraph1)
        .aspectRatio(4 / 3, contentMode: .fit)
    }
}

extension EarnProduct {

    @ViewBuilder
    func learnCardView(_ backgroundColor: Color) -> some View {
        switch self {
        case .staking:
            EarnLearningCardView(
                icon: .lockClosed,
                title: L10n.rewards.interpolating(title),
                message: L10n.learningStaking,
                backgroundColor: backgroundColor
            )
        case .savings:
            EarnLearningCardView(
                icon: .interestCircle,
                title: L10n.rewards.interpolating(title),
                message: L10n.learningSavings,
                backgroundColor: backgroundColor
            )
        case .active:
            EarnLearningCardView(
                icon: .prices,
                title: L10n.rewards.interpolating(title),
                message: L10n.learningActive,
                backgroundColor: backgroundColor
            )
        default:
            EarnLearningCardView(
                icon: .paperclip,
                title: L10n.rewards.interpolating(title),
                message: L10n.learningDefault.interpolating(title),
                backgroundColor: backgroundColor
            )
        }
    }
}

struct EarnLearning_Previews: PreviewProvider {

    static let products: [EarnProduct] = [
        .savings,
        .staking,
        .active
    ]

    static var previews: some View {
        Carousel(products, id: \.self, maxVisible: 1.8) { product in
            product.learnCardView(Color.semantic.light).context(
                [blockchain.ux.earn.discover.learn.id: product.value]
            )
        }
        .app(App.preview)
    }
}
