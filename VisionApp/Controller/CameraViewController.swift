//
//  ViewController.swift
//  VisionApp
//
//  Created by Mélodie Benmouffek on 30/01/2018.
//  Copyright © 2018 Mélodie Benmouffek. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLabelView: RoundedShadowView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
    @IBOutlet weak var flashButton: RoundedShadowButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

