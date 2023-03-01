import BlockchainUI
import SwiftUI

typealias L10n = LocalizationConstants.Coin.News

struct CoinNewsSectionView: View {

    @State var articles: [String] = []
    @State var isEnabled: Bool?

    var body: some View {
        VStack {
            if isEnabled != false, articles.isNotEmpty {
                SectionHeader(
                    title: L10n.news,
                    variant: .superapp
                )
                Carousel(articles, id: \.self, maxVisible: 1.4, snapping: true) { id in
                    CoinNewsCardView()
                        .context(
                            [
                                blockchain.api.news.asset.article.id: id,
                                blockchain.ux.asset.news.article.id: id
                            ]
                        )
                }
            }
        }
        .binding(
            .subscribe($articles, to: blockchain.api.news.asset.articles),
            .subscribe($isEnabled, to: blockchain.ux.asset.news.is.enabled)
        )
    }
}

let iso8601: ISO8601DateFormatter = with(ISO8601DateFormatter()) { dateFormatter in
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
}

let dateFormatter: DateFormatter = with(DateFormatter()) { dateFormatter in
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .medium
}

struct CoinNewsCardView: View {

    struct Article: Decodable, Equatable {
        let author: String?
        let date: String
        let image: URL?
        let link: URL
        let source: String
        let title: String
    }

    @BlockchainApp var app

    @State var article: Article?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
            if let article {
                VStack(alignment: .leading) {
                    AsyncMedia(
                        url: article.image,
                        failure: { _ in Color.semantic.light }
                    )
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .resizingMode(.aspectFit)
                    Text(article.title)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                        .lineLimit(3)
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .layoutPriority(0)
                    HStack {
                        if let author = article.author {
                            Text(author)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        let date = iso8601.date(from: article.date)
                        if article.author.isNotNilOrEmpty, date.isNotNil {
                            Circle().frame(width: 2.pt, height: 2.pt)
                        }
                        if let date {
                            Text(dateFormatter.string(from: date))
                                .layoutPriority(1)
                        }
                    }
                    .typography(.caption2)
                    .foregroundColor(.semantic.body)
                    Text(L10n.publishedBy.interpolating(article.source))
                        .typography(.caption2)
                        .foregroundColor(.semantic.body.opacity(0.8))
                }
                .padding(16.pt)
                .multilineTextAlignment(.leading)
                .batch(
                    .set(blockchain.ux.asset.news.article.paragraph.row.tap.then.enter.into, to: blockchain.ux.web[article.link])
                )
            } else {
                ProgressView()
            }
        }
        .onTapGesture {
            $app.post(event: blockchain.ux.asset.news.article.paragraph.row.tap)
        }
        .post(lifecycleOf: blockchain.ux.asset.news.article.paragraph.row, update: article)
        .binding(
            .subscribe($article, to: blockchain.api.news.asset.article)
        )
        .typography(.paragraph1)
        .aspectRatio(1, contentMode: .fit)
    }
}
