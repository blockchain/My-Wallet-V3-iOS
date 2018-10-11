//
//  BCPriceMarker.swift
//  Blockchain
//
//  Created by Maurice Achtenhagen on 4/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Charts

open class BCPriceMarker: MarkerImage {
    @objc open var color: UIColor
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()

    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: AnyObject]()

    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }

    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0 {
            offset.x = -origin.x + padding
        } else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0 {
            offset.y = height + padding
        } else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }

    open override func draw(context: CGContext, point: CGPoint) {
        guard let label = label else { return }

        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        let origin = CGPoint(x: point.x + offset.x, y: point.y + offset.y)

        var rect = CGRect(origin: origin, size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height

        context.saveGState()

        UIColor(red: 16/255, green: 173/255, blue: 228/255, alpha: 1).setStroke()
        UIColor.white.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        path.fill()
        path.stroke()

        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom

        UIGraphicsPushContext(context)

        label.draw(in: rect, withAttributes: _drawAttributes)

        UIGraphicsPopContext()

        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let data = entry.data as? NSDictionary else {
            fatalError("Chart data entry has no data set")
        }
        guard let currency = data["currency"] as? String,
            let symbol = data["symbol"] as? String else {
                fatalError("Chart data entry has bad data")
        }
        guard let number = NumberFormatter.fiatString(from: entry.y) else {
            Logger.shared.warning("Could not generate number string from chart data entry")
            setLabel(currency)
            return
        }
        let labelText = String(format: "%@\n%@%@", currency, symbol, number)
        setLabel(labelText)
    }

    @objc open func setLabel(_ newLabel: String) {
        label = newLabel

        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor

        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero

        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
