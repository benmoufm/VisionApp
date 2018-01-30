//
//  RoundedShadowImageView.swift
//  VisionApp
//
//  Created by Mélodie Benmouffek on 30/01/2018.
//  Copyright © 2018 Mélodie Benmouffek. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.75
        layer.cornerRadius = 15.0
    }
}
