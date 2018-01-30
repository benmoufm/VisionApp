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
    @IBOutlet weak var roundedLabelView: UIView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var flashButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

