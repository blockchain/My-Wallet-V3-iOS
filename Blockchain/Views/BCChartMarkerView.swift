//
//  BCChartMarkerView.swift
//  Blockchain
//
//  Created by kevinwu on 10/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

import Charts

class BCChartMarkerView: MarkerView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.brandTertiary.cgColor
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
        self.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(x: -(self.bounds.size.width/2), y: -(self.bounds.size.height/2))
    }

    private func dateFromTimeInterval(timeInterval: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM dd, HH:mm"
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateFormatter.string(from: date)
    }
}
