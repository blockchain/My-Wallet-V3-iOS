//
//  LocationSuggestionCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class LocationSuggestionCell: UITableViewCell {

    func configure(with suggestion: LocationSuggestion) {
        
        let titleAttributes = [NSAttributedString.Key.font: LocationSuggestionCell.titleFont(),
                               NSAttributedString.Key.foregroundColor: UIColor.gray5]
        let titleHighlightedAttributes = [NSAttributedString.Key.font: LocationSuggestionCell.highlightedTitleFont(),
                                          NSAttributedString.Key.foregroundColor: UIColor.gray5]

        let subtitleAttributes = [NSAttributedString.Key.font: LocationSuggestionCell.subtitleFont(),
                                  NSAttributedString.Key.foregroundColor: UIColor.gray5]
        let subtitleHighlightedAttributes = [NSAttributedString.Key.font: LocationSuggestionCell.highlightedSubtitleFont(),
                                             NSAttributedString.Key.foregroundColor: UIColor.gray5]

        let attributedTitle = NSMutableAttributedString(string: suggestion.title, attributes: titleAttributes)
        let attributedSubtitle = NSMutableAttributedString(string: suggestion.subtitle, attributes: subtitleAttributes)

        suggestion.titleHighlights.forEach({
            attributedTitle.addAttributes(titleHighlightedAttributes, range: $0)
        })

        suggestion.subtitleHighlights.forEach({
            attributedSubtitle.addAttributes(subtitleHighlightedAttributes, range: $0)
        })

        textLabel?.attributedText = attributedTitle
        detailTextLabel?.attributedText = attributedSubtitle
    }

    static func titleFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.SmallMedium) ?? UIFont.systemFont(ofSize: 17)
    }

    static func highlightedTitleFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.SmallMedium) ?? UIFont.systemFont(ofSize: 17)
    }

    static func subtitleFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraExtraExtraSmall) ?? UIFont.systemFont(ofSize: 13)
    }

    static func highlightedSubtitleFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.ExtraExtraExtraSmall) ?? UIFont.systemFont(ofSize: 13)
    }
}
