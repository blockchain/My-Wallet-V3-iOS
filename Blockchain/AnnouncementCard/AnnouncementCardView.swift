//
//  AnnouncementCardView.swift
//  Blockchain
//
//  Created by Maurice A. on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class AnnouncementCardView: UIView {

    // MARK: - IBOutlets

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var closeButton: UIButton!

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
