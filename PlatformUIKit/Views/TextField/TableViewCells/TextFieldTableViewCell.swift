//
//  TextFieldTableViewCell.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 17/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class TextFieldTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    public var bottomInset: CGFloat {
        get {
            textFieldView.bottomInset
        }
        set {
            textFieldView.bottomInset = newValue
        }
    }
    
    private let textFieldView: TextFieldView = .init()
    
    // MARK: - Lifecycle
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(textFieldView)
        textFieldView.layoutToSuperview(axis: .horizontal, offset: 24)
        textFieldView.layoutToSuperview(axis: .vertical)
        textFieldView.layout(dimension: .height, to: 80, priority: .defaultLow)
    }
        
    public func setup(viewModel: TextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController,
                      scrollView: UIScrollView) {
        textFieldView.setup(
            viewModel: viewModel,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: scrollView
        )
    }
}
