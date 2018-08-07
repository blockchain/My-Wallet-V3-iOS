//
//  LocationSuggestion.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

struct LocationSuggestion: SearchSelection {

    typealias HighlightRanges = [NSRange]

    let title: String
    let subtitle: String
    let titleHighlights: HighlightRanges
    let subtitleHighlights: HighlightRanges
}
