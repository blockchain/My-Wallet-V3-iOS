//
//  Colors.swift
//  Blockchain
//
//  Created by Maurice A. on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

//: Pro tip: prefix color names in assets catalog with `Color` for easy filtering
//: Adding a new color: create entry in Images.xcassets, then add constant here
//: Colors in Images.xcassets will be used once iOS 11 is the minimum targeted version
@objc
extension UIColor {

    // MARK: - Brand-specific Colors

    static let aqua = #colorLiteral(red: 0, green: 0.7294117647, blue: 0.737254902, alpha: 1)

    static let brandPrimary = #colorLiteral(red: 0, green: 0.2901960784, blue: 0.4862745098, alpha: 1)

    static let brandSecondary = #colorLiteral(red: 0.06274509804, green: 0.6784313725, blue: 0.8941176471, alpha: 1)

    static let brandTertiary = #colorLiteral(red: 0.6980392157, green: 0.8352941176, blue: 0.8980392157, alpha: 1)

    static let brandQuaternary = #colorLiteral(red: 0.8549019608, green: 0.9490196078, blue: 0.9843137255, alpha: 1)

    static let brandYellow = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.3843137255, alpha: 1)

    static let brandYellowLighter = #colorLiteral(red: 1, green: 0.9019607843, blue: 0.7058823529, alpha: 1)

    static let error = #colorLiteral(red: 0.7921568627, green: 0.2274509804, blue: 0.2352941176, alpha: 1)
    
    static let gray1 = #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)

    static let gray2 = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)

    static let gray3 = #colorLiteral(red: 0.6, green: 0.6078431373, blue: 0.6196078431, alpha: 1)

    static let gray4 = #colorLiteral(red: 0.4588235294, green: 0.462745098, blue: 0.4745098039, alpha: 1)

    static let gray5 = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.337254902, alpha: 1)

    static let gray6 = #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1)

    static let grayBlue = #colorLiteral(red: 0.4745098039, green: 0.6196078431, blue: 0.6980392157, alpha: 1)

    static let green = #colorLiteral(red: 0, green: 0.6549019608, blue: 0.4352941176, alpha: 1)

    static let marketingPrimary = #colorLiteral(red: 0.2078431373, green: 0.3450980392, blue: 0.6588235294, alpha: 1)

    static let marketingSecondary = #colorLiteral(red: 0.08235294118, green: 0.2274509804, blue: 0.3843137255, alpha: 1)

    static let red = #colorLiteral(red: 0.9490196078, green: 0.4235294118, blue: 0.3411764706, alpha: 1)

    // MARK: - App-specific Colors

    static let emptyChart = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)

    static let grayLine = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)

    static let keyPadButton = #colorLiteral(red: 0.831372549, green: 0.8509803922, blue: 0.8666666667, alpha: 1)

    static let lightGray = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9725490196, alpha: 1)

    static let pending = #colorLiteral(red: 0.9490196078, green: 0.5450980392, blue: 0.1882352941, alpha: 1)

    static let verified = #colorLiteral(red: 0.01176470588, green: 0.662745098, blue: 0.4470588235, alpha: 1)

    static let unverified = #colorLiteral(red: 0.86, green: 0.16, blue: 0.16, alpha: 1)
}
