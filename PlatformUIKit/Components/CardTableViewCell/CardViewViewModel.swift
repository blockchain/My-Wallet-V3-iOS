//
//  CardViewViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/1/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public struct CardViewViewModel {
    
    public var identifier: String {
        titleContent.text + "." + descriptionContent.text
    }
    
    let titleContent: LabelContent
    let descriptionContent: LabelContent
    
    public struct Style {
        let titleFont: UIFont
        let titleTextColor: UIColor
        let descriptionFont: UIFont
        let descriptionTextColor: UIColor
        
        static let transaction: Style = .init(
            titleFont: .main(.semibold, 14.0),
            titleTextColor: .textFieldText,
            descriptionFont: .main(.medium, 12.0),
            descriptionTextColor: .descriptionText
        )
    }
    
    public init(title: String, description: String, style: Style) {
        titleContent = .init(
            text: title,
            font: style.titleFont,
            color: style.titleTextColor,
            alignment: .left,
            accessibility: .none
        )
        
        descriptionContent = .init(
            text: description,
            font: style.descriptionFont,
            color: style.descriptionTextColor,
            alignment: .left,
            accessibility: .none
        )
    }
}

extension CardViewViewModel {
    public static func transactionViewModel(with title: String,
                                            description: String) -> CardViewViewModel {
        .init(title: title, description: description, style: .transaction)
    }
}

extension CardViewViewModel: Equatable {
    public static func ==(lhs: CardViewViewModel, rhs: CardViewViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
