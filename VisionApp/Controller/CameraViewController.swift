//
//  ViewController.swift
//  VisionApp
//
//  Created by Mélodie Benmouffek on 30/01/2018.
//  Copyright © 2018 Mélodie Benmouffek. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVSpeechSynthesizerDelegate {
    //MARK: - Outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLabelView: RoundedShadowView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
    @IBOutlet weak var flashButton: RoundedShadowButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: - Variables
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
        activityIndicator.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1920x1080
        let backCamera = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput!)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.videoGravity = .resizeAspect
            previewLayer.connection?.videoOrientation = .portrait
            cameraView.layer.addSublayer(previewLayer!)
            addTapGesture()
            captureSession.startRunning()
        } catch {
            debugPrint(error as Any)
        }
    }

    func synthesizeSpeech(forString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }

    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        cameraView.addGestureRecognizer(tap)
    }

    @objc func didTapCameraView() {
        cameraView.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        switch flashControlState {
        case .off:
            settings.flashMode = .off
        case .on:
            settings.flashMode = .on
        }
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }

    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        for classification in results {
            if classification.confidence < 0.5 {
                let unknownObjectMessage = "I'm not sure what this is. Please try again."
                let unknownObjectMessageFR = "Je ne sais pas ce que c'est. Essayez encore."
                synthesizeSpeech(forString: unknownObjectMessageFR)
                identificationLabel.text = unknownObjectMessage
                confidenceLabel.text = ""
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                identificationLabel.text = identification
                confidenceLabel.text = "CONFIDENCE : \(confidence)%"
                let completeSentenceFR = "Ça ressemble à un \(identification) et je suis sûr à \(confidence) pourcents."
                synthesizeSpeech(forString: completeSentenceFR)
                break
            }
        }
    }

    //MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            let image = UIImage(data: photoData!)
            capturedImageView.image = image
        }
    }

    //MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        cameraView.isUserInteractionEnabled = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    //MARK: - Actions
    @IBAction func flashButtonPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashButton.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashButton.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
}

