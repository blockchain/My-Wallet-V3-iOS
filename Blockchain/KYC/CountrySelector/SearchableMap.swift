//
//  SearchableMap.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SearchableItem {
    /// The name of the item
    var name: String { get }
}

/// Helper map object to be used when displaying a list of items in a list that can
/// be searched.
class SearchableMap<Item: SearchableItem> {
    private var allItems: [Item]?
    private var backingMap = [String: [Item]]()

    var searchText: String? {
        didSet {
            guard let items = allItems else {
                return
            }
            guard let searchText = searchText?.lowercased() else {
                updateMap(with: items)
                return
            }
            let filteredItems = items.filter { $0.name.lowercased().starts(with: searchText) }
            updateMap(with: filteredItems)
        }
    }

    var firstLetters: [String] {
        return Array(backingMap.keys).sorted(by: { $0 < $1 })
    }

    var keys: Dictionary<String, [Item]>.Keys {
        return backingMap.keys
    }

    func items(firstLetter: String) -> [Item]? {
        return backingMap[firstLetter]
    }

    func setAllItems(_ items: [Item]) {
        allItems = items
        allItems?.sort(by: { $0.name < $1.name })
        updateMap(with: items)
    }

    func item(at indexPath: IndexPath) -> Item? {
        let firstLetter = firstLetters[indexPath.section]
        guard let itemsInSection = backingMap[firstLetter] else {
            return nil
        }
        return itemsInSection[indexPath.row]
    }

    private func updateMap(with items: [Item]) {
        backingMap.removeAll()

        let itemSectionHeaders = items.compactMap({ item -> String? in
            guard let firstChar = item.name.first else {
                return nil
            }
            return String(firstChar).uppercased()
        }).unique

        itemSectionHeaders.forEach { firstLetter in
            backingMap[firstLetter] = items.filter {
                guard let firstChar = $0.name.first else { return false }
                return String(firstChar).uppercased() == firstLetter
            }
        }
    }
}
