// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Localization
import PlatformUIKit
import ToolKit

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        fromNib(named: AboutView.objectName, in: .module)
        logoImageView.tintColor = .semantic.body
        var hash = ""
        if let info = MainBundleProvider.mainBundle.infoDictionary {
            hash = (info[Constants.commitHash] as? String ?? "")
        }

        let appVersion = Bundle.applicationVersion ?? ""
        let buildNumber = Bundle.applicationBuildVersion ?? ""
        var version = "\(LocalizationIDs.version) \(appVersion) (\(buildNumber))"
        if BuildFlag.isInternal {
            version = "\(version) - \(hash)"
        }

        versionLabel.content = .init(
            text: version,
            font: .main(.medium, 12.0),
            color: .semantic.muted,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.versionLabel)
        )

        copyrightLabel.content = .init(
            text: String(format: "\(LocalizationIDs.copyright)", Date().currentYear),
            font: .main(.medium, 12.0),
            color: .semantic.muted,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.copyrightLabel)
        )
    }

    static func estimatedHeight(for width: CGFloat) -> CGFloat {
        let version = NSAttributedString(
            string: LocalizationIDs.version,
            attributes: [.font: UIFont.main(.medium, 12.0)]
        )
        .heightForWidth(width: width - horizontalPadding)

        let copyright = NSAttributedString(
            string: LocalizationIDs.copyright,
            attributes: [.font: UIFont.main(.medium, 12.0)]
        )
        .heightForWidth(width: width - horizontalPadding)

        return verticalPadding + version + copyright + logoHeight
    }
}

extension Date {

    var currentYear: Int {
        Calendar.current.component(.year, from: self)
    }
}
