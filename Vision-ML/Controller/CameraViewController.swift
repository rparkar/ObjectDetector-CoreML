//
//  CameraViewController.swift
//  Vision-ML
//
//  Created by Rehan Parkar on 2018-06-30.
//  Copyright © 2018 Rehan Parkar. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case on
    case off
}

class CameraViewController: UIViewController {

    //outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var roundedLabelsView: RoundedShadowView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //variables
    var captureSession : AVCaptureSession!
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
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080

        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)

        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)

            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }

            cameraOutput = AVCapturePhotoOutput()

            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

            cameraView.layer.addSublayer(previewLayer!)

            cameraView.addGestureRecognizer(tap)
            
            captureSession.startRunning()

        }
        catch {
            debugPrint(error)
        }
    }

    
    @objc func didTapCameraView() {
        cameraView.isUserInteractionEnabled = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first! //for generic photos/ no live photos
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String: 160]
//                settings.previewPhotoFormat = previewFormat
        
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        
        guard let results = request.results as? [VNClassificationObservation] else {return}
        for classification in results {
            if classification.confidence < 0.5 {
                let unknownObjectMsg = "I am not sure what this is. Please try again"
                self.identificationLabel.text = unknownObjectMsg
                synthesizeSpeech(fromString: unknownObjectMsg)
                self.confidenceLabel.text = ""
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.identificationLabel.text = identification
                self.confidenceLabel.text = "CONFIDENCE: \(confidence)%"
                let completeSentence = "This looks like a \(identification) and I am \(confidence) percent sure"
                synthesizeSpeech(fromString: completeSentence)
                break
            }
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func flashButtonWasPressed(_ sender: Any) {
        
        switch flashControlState {
        case .off:
            flashButton.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on: flashButton.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
    
    

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            debugPrint(error)
        } else {
            photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                
                try handler.perform([request])
            } catch {
                debugPrint(error)
                
            }
            
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
    
}


extension CameraViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.cameraView.isUserInteractionEnabled = true
        spinner.isHidden = true
        spinner.stopAnimating()
    }
}




