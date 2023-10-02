// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A simple UIStackView with three UILabel
/// Hugging and Compression Resistance Priorities already set.
/// Can be used as is, or may be sub-classed.
class TwoLabelStackView: UIStackView {
    let topLabel = UILabel()
    let middleLabel = UILabel()
    let middleStackView = UIStackView()

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        superSetup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        superSetup()
    }

    /// Clear all text labels and set them visible.
    func clear() {
        [topLabel, middleLabel].forEach { label in
            label.text = ""
            label.isHidden = false
        }
    }

    private func superSetup() {
        axis = .vertical
        spacing = 4
        distribution = .fillEqually
        middleStackView.axis = .horizontal
        middleStackView.alignment = .center
        middleStackView.spacing = 4
        middleStackView.distribution = .fillProportionally
        middleStackView.addArrangedSubview(middleLabel)
        addArrangedSubview(topLabel)
        addArrangedSubview(middleStackView)
        topLabel.verticalContentHuggingPriority = UILayoutPriority(rawValue: 252)
        contentHuggingPriority = (.penultimateHigh, .penultimateHigh)
        contentCompressionResistancePriority = (.penultimateHigh, .penultimateHigh)
        clear()
    }
}
