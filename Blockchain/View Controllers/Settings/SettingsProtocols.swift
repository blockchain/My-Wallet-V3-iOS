//
//  SettingsProcols.swift
//  Blockchain
//
//  Created by Justin on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol Togglable {
    var toggleSwitch: UISwitch! { get set }
}

protocol CustomDetailCell {
    var subtitle: UILabel? { get set }
}

protocol CustomSettingCell {
    var title: UILabel? { get set }
}

protocol CustomToggleCell: Togglable {
    var nibName: String? { get set }
}

protocol AppSettingsController {
    func reload()
    func verifyEmailTapped()
    func changeTwoStepTapped()
    func updateEmailAndMobileStrings()
    func showBackup()
    func showTwoStep()
}
