import BlockchainUI
import SwiftUI

public struct WireTransferView: View {

    @BlockchainApp var app

    let story = blockchain.ux.payment.method.wire.transfer

    @State private var title: String = "Add a Bank"
    @State private var error: Nabu.Error?
    @State private var headers: [String]?
    @State private var sections: [String] = []
    @State private var footers: [String]?
    @State private var isSynchronized: Bool = false

    public init() {}

    public var body: some View {
        VStack {
            if let error {
                ErrorView(
                    ux: UX.Error(nabu: error),
                    navigationBarClose: false,
                    dismiss: { $app.post(event: story.article.plain.navigation.bar.button.close.tap) }
                )
            } else if !isSynchronized {
                Spacer()
                BlockchainProgressView()
                Spacer()
            } else if headers.isNilOrEmpty, sections.isEmpty, footers.isNilOrEmpty {
                ErrorView(
                    ux: UX.Error(
                        error: Nabu.Error(
                            id: blockchain.ux.payment.method.wire.transfer.failed(\.id),
                            code: .unknown,
                            type: .unknown,
                            ux: UX.Dialog(
                                title: LocalizationConstants.Transaction.wireTransferEmptyTitle,
                                message: LocalizationConstants.Transaction.wireTransferEmptyMessage
                            )
                        )
                    ),
                    navigationBarClose: false,
                    dismiss: { $app.post(event: story.article.plain.navigation.bar.button.close.tap) }
                )
            } else {
                List {
                    if let headers, headers.isNotEmpty {
                        Section {
                            ForEach(headers, id: \.self) { header in
                                HeaderFooterView(id: blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.header)
                                    .context([blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.header.id: header])
                            }
                        }
                        .listRowBackground(Color.clear)
                        .backport.hideListRowSeparator()
                        .listRowInsets(.zero)
                        .textCase(nil)
                    }
                    if sections.isNotEmpty {
                        ForEach(sections, id: \.self) { section in
                            SectionView()
                                .context([blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.section.id: section])
                        }
                    }
                    if let footers, footers.isNotEmpty {
                        Section {
                            ForEach(footers, id: \.self) { footer in
                                HeaderFooterView(id: blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.footer)
                                    .context([blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.footer.id: footer])
                            }
                        }
                        .listRowBackground(Color.clear)
                        .backport.hideListRowSeparator()
                        .listRowInsets(.zero)
                        .textCase(nil)
                    }
                }
                .hideScrollContentBackground()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .primaryNavigation(
            title: title,
            trailing: {
                IconButton(
                    icon: Icon.closeCirclev3.small(),
                    action: { $app.post(event: story.article.plain.navigation.bar.button.close.tap) }
                )
            }
        )
        .listStyle(.insetGrouped)
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe($error, to: blockchain.api.nabu.gateway.payments.accounts.simple.buy)
        }
        .bindings(
            managing: { update in
                switch update {
                case .didSynchronize: isSynchronized = true
                default: break
                }
            }
        ) {
            subscribe($title, to: blockchain.api.nabu.gateway.payments.accounts.simple.buy.title)
            subscribe($headers, to: blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.headers)
            subscribe($sections, to: blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.sections)
            subscribe($footers, to: blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.footers)
        }
        .batch {
            set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }
}

extension WireTransferView {

    public struct RowModel: Codable, Hashable {
        public let copy: Bool?
        public let help: String?
        public let id: String
        public let important: Bool?
        public let title: String
        public let value: String
        public let icon: UX.Icon?
    }

    struct ActionsView: View {

        @BlockchainApp var app

        let row: L & I_blockchain_api_nabu_gateway_payments_accounts_simple_buy_content_type_row

        @State private var isSynchronized: Bool = false
        @State private var actions: [String] = []

        var body: some View {
            content.bindings(managing: update) {
                subscribe($actions, to: row.button.actions)
            }
        }

        @ViewBuilder var content: some View {
            if actions.isNotEmpty {
                VStack {
                    ForEach(actions.chunks(ofCount: 3).array, id: \.self) { actions in
                        HStack {
                            ForEach(actions, id: \.self) { action in
                                withBinding(to: row.button.action[action].title, as: String.self) { title in
                                    SmallMinimalButton(title: title) { $app.post(event: row.button.action[action].tap) }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else if !isSynchronized {
                ProgressView()
            }
        }

        func update(_ update: Bindings.Update) {
            switch update {
            case .didSynchronize:
                isSynchronized = true
            default:
                break
            }
        }
    }

    @MainActor
    struct HeaderFooterView: View {

        @BlockchainApp var app

        let id: L & I_blockchain_api_nabu_gateway_payments_accounts_simple_buy_content_type_row

        var body: some View {
            if #available(iOS 16.0, *) {
                content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
            } else {
                content
            }
        }

        @ViewBuilder var content: some View {
            withBinding(to: id, as: RowModel.self) { data in
                if data.important ?? false {
                    AlertCard(
                        title: data.title,
                        message: data.value,
                        variant: .warning,
                        isBordered: true,
                        backgroundColor: Color.semantic.light,
                        footer: { ActionsView(row: id) }
                    )
                } else {
                    TableRow(
                        leading: {
                            if let icon = data.icon {
                                AsyncMedia(url: icon.url)
                                    .scaledToFit()
                                    .frame(maxHeight: 44.pt)
                            }
                        },
                        title: data.title,
                        byline: data.value,
                        footer: { ActionsView(row: id) }
                    )
                }
            }
        }
    }

    @MainActor
    struct SectionView: View {

        let section = blockchain.api.nabu.gateway.payments.accounts.simple.buy.content.section

        @State private var title: String = ""
        @State private var rows: [String] = []

        var body: some View {
            Section(
                content: {
                    ForEach(rows, id: \.self) { row in
                        RowView(id: section.row)
                            .context([section.row.id: row])
                    }
                },
                header: { sectionHeader(title: title) }
            )
            .bindings {
                subscribe($title, to: section.title)
                subscribe($rows, to: section.rows)
            }
        }

        @ViewBuilder
        func sectionHeader(title: String) -> some View {
            Text(title)
                .typography(.body2)
                .textCase(nil)
                .foregroundColor(.semantic.body)
                .padding(.bottom, Spacing.padding1)
        }
    }

    @MainActor
    struct RowView: View {

        @BlockchainApp var app

        let id: L & I_blockchain_api_nabu_gateway_payments_accounts_simple_buy_content_type_row

        @State private var isSynchronized: Bool = false
        @State private var data: RowModel?
        @State private var copied: Bool = false

        var body: some View {
            if #available(iOS 16.0, *) {
                content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
            } else {
                content
            }
        }

        @ViewBuilder var content: some View {
            Group {
                if isSynchronized, data.isNil {
                    EmptyView()
                } else if let data {
                    TableRow(
                        leading: {
                            if let icon = data.icon {
                                AsyncMedia(url: icon.url)
                                    .scaledToFit()
                                    .frame(maxHeight: 44.pt)
                            }
                        },
                        title: {
                            if data.title.isNotEmpty {
                                HStack {
                                    Text(data.title)
                                        .typography(.caption1)
                                        .foregroundColor(.semantic.body)
                                    if data.help.isNotNilOrEmpty {
                                        IconButton(icon: Icon.questionCircle) {
                                            $app.post(
                                                event: id.button.help.tap,
                                                context: [
                                                    blockchain.ux.payment.method.wire.transfer.help: data,
                                                    blockchain.ui.type.action.then.enter.into.detents: [
                                                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                                    ]
                                                ]
                                            )
                                        }
                                        .frame(width: 14.pt, height: 14.pt)
                                    }
                                    Spacer()
                                }
                            }
                        },
                        byline: {
                            Text(data.value)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                        },
                        trailing: {
                            if data.copy ?? true {
                                Group {
                                    if copied {
                                        Icon.check.color(.semantic.success)
                                    } else {
                                        Icon.copy.color(.semantic.muted)
                                    }
                                }
                                .foregroundColor(.semantic.muted)
                                .frame(width: 20.pt, height: 20.pt)
                            }
                        },
                        footer: { ActionsView(row: id) }
                    )
                    .contentShape(Rectangle())
                    .tableRowBackground(Color.clear)
                    .listRowBackground(Color.semantic.background)
                    .onTapGesture {
                        if data.copy ?? true {
                            $app.post(event: id.button.copy.tap)
                        }
                        Task { @MainActor in
                            copied = true
                            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                            copied = false
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .bindings {
                subscribe($data, to: id)
            }
        }
    }
}

public struct WireTransferRowHelp: View {

    @BlockchainApp var app

    let story = blockchain.ux.payment.method.wire.transfer.help
    let data: WireTransferView.RowModel

    public init(_ row: WireTransferView.RowModel) {
        self.data = row
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(data.title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Spacer()
            }
            .padding(.vertical)
            Text(data.value)
                .typography(.caption2)
                .foregroundColor(.semantic.muted)
            if let help = data.help {
                Text(help)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)
            }
        }
        .padding()
        .background(Color.semantic.light.ignoresSafeArea())
        .overlay(
            IconButton(
                icon: Icon.closeCirclev3,
                action: { $app.post(event: story.article.plain.navigation.bar.button.close.tap) }
            )
            .padding(),
            alignment: .topTrailing
        )
        .batch {
            set(story.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }
}
