// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import SwiftUI
import ToolKit

/// A list of data which can be filtered by a search term
public struct SearchableList<Data, Content: View, Empty: View>: View where
    Data: RandomAccessCollection,
    Data.Element: CustomStringConvertible & Identifiable
{
    /// Layout constants for the search bar height and padding
    public var layout: Layout

    public var placeholder: String
    public var accessory: Image
    public var clear: Image

    internal var content: (Data.Element) -> Content
    internal var empty: () -> Empty

    @ObservedObject private var search: SearchObservableObject<Data>

    public init(
        _ data: Data,
        tolerance: Double = 0.3,
        placeholder: String = "Search",
        accessory: Image = Image(systemName: "magnifyingglass"),
        clear: Image = Image(systemName: "xmark"),
        layout: Layout = Layout(),
        algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: false),
        @ViewBuilder content: @escaping (Data.Element) -> Content,
        @ViewBuilder empty: @escaping () -> Empty
    ) {
        _search = .init(initialValue: SearchObservableObject(data, tolerance: tolerance, algorithm: algorithm))
        self.placeholder = placeholder
        self.accessory = accessory
        self.clear = clear
        self.layout = layout
        self.content = content
        self.empty = empty
    }

    public var body: some View {
        VStack {
            Group {
                Divider()
                TextField(placeholder, text: $search.term)
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                    .overlay(
                        accessoryOverlay,
                        alignment: .trailing
                    )
                    .frame(height: layout.searchBarHeight, alignment: .center)
                    .padding([.leading, .trailing], layout.searchBarLeadingTrailingPadding)
                Divider()
            }
            .frame(width: nil)
            if search.data.isEmpty {
                empty()
            } else {
                List(search.data) { item in
                    content(item).listRowInsets(EdgeInsets())
                }
                .listStyle(PlainListStyle())
            }
        }
    }

    @ViewBuilder var accessoryOverlay: some View {
        if search.isSearching {
            Button(
                action: { search.term = "" },
                label: { clear.foregroundColor(.semantic.body) }
            )
        } else {
            accessory
                .foregroundColor(.semantic.body)
        }
    }
}

extension SearchableList {

    public struct Layout: Codable, Equatable {

        public var searchBarHeight: CGFloat = 58
        public var searchBarLeadingTrailingPadding: CGFloat = 24

        public init(
            searchBarHeight: CGFloat = 58,
            searchBarLeadingTrailingPadding: CGFloat = 24
        ) {
            self.searchBarHeight = searchBarHeight
            self.searchBarLeadingTrailingPadding = searchBarLeadingTrailingPadding
        }
    }
}

public class SearchObservableObject<Data>: ObservableObject where
    Data: RandomAccessCollection,
    Data.Element: CustomStringConvertible
{

    @Published public var data: [Data.Element]
    @Published public var term: String = ""

    /// True if the list has a search term and is filtering the data
    public var isSearching: Bool { !term.isEmpty }

    let source: Data

    /// A number between 0 and 1 to determine how likely a search term is to appear in the filtered list.
    /// 0 means exact match and 1 means no similarity, this defaults to 0.3 and is only used in some of the
    /// distance algorithms such as JaroWrinkler
    let tolerance: Double

    /// The algorithm used to compute the distance between two strings, defaults to FuzzyAlgorithm with
    /// case sensitive comparisons
    let algorithm: StringDistanceAlgorithm

    private var bag: Set<AnyCancellable> = []

    public init(
        _ source: Data,
        tolerance: Double = 0.3,
        algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: false)
    ) {
        self.source = source
        _data = .init(initialValue: Array(source))
        self.tolerance = tolerance
        self.algorithm = algorithm

        $term
            .sink(to: SearchObservableObject.filter(by:), on: self)
            .store(in: &bag)
    }

    public func filter(by searchTerm: String) {
        guard !searchTerm.isEmpty else {
            return data = Array(source)
        }
        data = source
            .filter { $0.description.distance(between: searchTerm, using: algorithm) < tolerance }
            .sorted { l, r in
                l.description.distance(between: searchTerm, using: algorithm)
                    < r.description.distance(between: searchTerm, using: algorithm)
            }
    }
}

#if DEBUG

struct SearchableListExample: CustomStringConvertible, Identifiable, ExpressibleByStringLiteral {

    var id: String { description }
    var description: String

    init(_ value: String) {
        self.description = value
    }

    init(stringLiteral value: String) {
        self.description = value
    }
}

struct SearchableList_Previews: PreviewProvider {

    static var previews: some View {
        SearchableList(
            [
                "Dog" as SearchableListExample,
                "Cat",
                "Sheep",
                "Big Dog",
                "Golden Retriever Dog",
                "Cow",
                "Pig"
            ],
            content: { item in
                Text(item.description)
            },
            empty: {
                VStack {
                    Spacer()
                    Text("No results found")
                    Spacer()
                }
            }
        )
    }
}
#endif
