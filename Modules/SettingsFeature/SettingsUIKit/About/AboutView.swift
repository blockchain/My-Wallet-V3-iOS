// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import SettingsKit

final class AboutView: UIView {

    // MARK: - Types

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.About
    private typealias LocalizationIDs = LocalizationConstants.Settings.About

    // MARK: - Constants

    private static let verticalPadding: CGFloat = 72.0
    private static let logoHeight: CGFloat = 16.0
    private static let horizontalPadding: CGFloat = 64.0

    // MARK: - Private IBOutlets

    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var copyrightLabel: UILabel!

    // MARK: - Setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        fromNib(named: AboutView.objectName)
        logoImageView.tintColor = .textFieldText
        var hash = ""
        if let info = Bundle.main.infoDictionary {
            hash = (info[Constants.commitHash] as? String ?? "")
        }
        var version = LocalizationIDs.version + " " + "\(Bundle.applicationVersion ?? "")"
        #if INTERNAL_BUILD
        version = "\(version) (\(hash))"
        #endif

        versionLabel.content = .init(
            text: version,
            font: .main(.medium, 12.0),
            color: .textFieldPlaceholder,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.versionLabel)
        )
        copyrightLabel.content = .init(
            text: LocalizationIDs.copyright,
            font: .main(.medium, 12.0),
            color: .textFieldPlaceholder,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.copyrightLabel)
        )
    }

    static func estimatedHeight(for width: CGFloat) -> CGFloat {
        let version = NSAttributedString(string: LocalizationIDs.version,
                                         attributes: [.font: UIFont.main(.medium, 12.0)])
            .heightForWidth(width: width - horizontalPadding)

        let copyright = NSAttributedString(string: LocalizationIDs.copyright,
                                           attributes: [.font: UIFont.main(.medium, 12.0)])
            .heightForWidth(width: width - horizontalPadding)

        return verticalPadding + version + copyright + logoHeight
    }
}
