import BlockchainUI
import SwiftUI

typealias L10n = LocalizationConstants.Coin.News

public struct NewsSectionView: View {

    @BlockchainApp var app

    let api: L & I_blockchain_api_news_type_list
    let limit: Int
    let seeAll: Bool

    @State private var articles: [String] = []

    public init(
        api: L & I_blockchain_api_news_type_list,
        limit: Int = 5,
        seeAll: Bool = true
    ) {
        self.api = api
        self.limit = limit
        self.seeAll = seeAll
    }

    public var body: some View {
        VStack {
            if articles.isNotEmpty {
                header
                ForEach(articles.prefix(limit), id: \.self) { id in
                    NewsRowView(api: api)
                        .context([api.article.id: id, blockchain.ux.news.article.id: id])
                }
            }
        }
        .bindings {
            subscribe($articles, to: api.articles)
        }
    }

    @ViewBuilder
    var header: some View {
        HStack {
            Text(L10n.news)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
            Button {
                $app.post(event: blockchain.ux.news.section.see.all.paragraph.button.minimal.tap, context: [blockchain.ux.news: api.key()])
            } label: {
                Text(L10n.seeAll)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.primary)
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .batch {
            set(blockchain.ux.news.section.see.all.paragraph.button.minimal.tap.then.enter.into, to: blockchain.ux.news.story)
        }
    }
}

public struct NewsStoryView: View {

    @BlockchainApp var app

    let api: L & I_blockchain_api_news_type_list

    @State private var articles: [String] = []

    public init(api: L & I_blockchain_api_news_type_list) {
        self.api = api
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(articles, id: \.self) { id in
                    NewsRowView(api: api)
                        .context([api.article.id: id, blockchain.ux.news.article.id: id])
                }
            }
            .padding(.top)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .primaryNavigation(
            title: L10n.news,
            trailing: {
                IconButton(
                    icon: .closeCirclev3,
                    action: {
                        $app.post(event: blockchain.ux.news.story.article.plain.navigation.bar.button.close.tap)
                    }
                )
            }
        )
        .bindings {
            subscribe($articles, to: api.articles)
        }
        .batch {
            set(blockchain.ux.news.story.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }
}

let iso8601: ISO8601DateFormatter = with(ISO8601DateFormatter()) { dateFormatter in
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
}

let dateFormatter: DateFormatter = with(DateFormatter()) { dateFormatter in
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .medium
}

public struct NewsRowView: View {

    public struct Article: Decodable, Equatable {
        public let author: String?
        public let date: String
        public let image: URL?
        public let link: URL
        public let source: String
        public let title: String
    }

    @BlockchainApp var app
    @State private var article: Article?

    public let api: L & I_blockchain_api_news_type_list

    public var body: some View {
        Group {
            if let article {
                VStack(alignment: .leading, spacing: .zero) {
                    HStack(alignment: .top) {
                        Text(article.title)
                            .lineLimit(3)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                            .layoutPriority(1)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        AsyncMedia(
                            url: article.image,
                            failure: { _ in Color.semantic.light },
                            placeholder: { Color.semantic.light.overlay(ProgressView()) }
                        )
                        .frame(width: 64.pt, height: 64.pt)
                        .resizingMode(.aspectFill)
                    }
                    .padding([.leading, .top, .trailing], 16.pt)
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                if let author = article.author {
                                    Text(author)
                                        .typography(.caption2)
                                        .foregroundColor(.semantic.body)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                let date = iso8601.date(from: article.date)
                                if article.author.isNotNilOrEmpty, date.isNotNil {
                                    Circle().frame(width: 2.pt, height: 2.pt)
                                }
                                if let date {
                                    Text(dateFormatter.string(from: date))
                                        .typography(.caption2)
                                        .foregroundColor(.semantic.body)
                                }
                            }
                            Text(L10n.publishedBy.interpolating(article.source))
                                .typography(.caption2)
                                .foregroundColor(.semantic.body.opacity(0.6))
                        }
                        Spacer()
                    }
                    .padding([.leading, .bottom, .trailing], 16.pt)
                }
                .batch {
                    set(blockchain.ux.news.article.paragraph.row.tap.then.enter.into, to: blockchain.ux.web[article.link])
                }
                .post(lifecycleOf: blockchain.ux.news.article.paragraph.row, update: article)
            } else {
                ProgressView()
            }
        }
        .background(
            RoundedRectangle(cornerSize: CGSize(width: 16, height: 16))
                .fill(Color.white)
        )
        .onTapGesture {
            $app.post(event: blockchain.ux.news.article.paragraph.row.tap)
        }
        .padding([.leading, .trailing], 16.pt)
        .bindings {
            subscribe($article, to: api.article)
        }
        .typography(.paragraph1)
    }
}

struct NewsRowView_Preview: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.semantic.light
                .ignoresSafeArea()
            NewsRowView(api: blockchain.api.news.asset)
                .context(
                    [
                        blockchain.api.news.asset.id: "BTC",
                        blockchain.api.news.asset.article.id: "123",
                        blockchain.ux.news.article.id: "123"
                    ]
                )
                .app(
                    App.preview.setup { app in
                        var article = L_blockchain_api_news_type_article.JSON()
                        article.title = "Stacks (STX) surges as Bitcoin NFT hype grows, but its blockchain activity raises concern"
                        article.link = "https://cointelegraph.com/news/stacks-stx-surges-as-bitcoin-nft-hype-grows-but-its-blockchain-activity-raises-concern"
                        article.date = "2023-02-28T21:30:00.000Z"
                        article.author = "Nivesh Rustgi"
                        article.image = "https://images.cointelegraph.com/images/840_aHR0cHM6Ly9zMy5jb2ludGVsZWdyYXBoLmNvbS91cGxvYWRzLzIwMjMtMDIvMzQzZjVkY2UtMmIyYi00Y2IxLTkwYmItYTBhNDhjZjlhMWM1LmpwZw==.jpg"
                        article.source = "CoinTelegraph"
                        try await app.set(
                            blockchain.api.news.napi[blockchain.api.news.asset(\.id)].data,
                            to: [
                                "article": ["123": article.any()],
                                "articles": ["123"]
                            ] as [String: Any]
                        )
                    }
                )
        }
    }
}
