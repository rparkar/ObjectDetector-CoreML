//
//  CameraViewController.swift
//  Vision-ML
//
//  Created by Rehan Parkar on 2018-06-30.
//  Copyright © 2018 Rehan Parkar. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    //outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var roundedLabelsView: RoundedShadowView!
    
    //variables
    var captureSession : AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
        
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
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first! //for generic photos/ no live photos
        
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            debugPrint(error)
        } else {
            photo.fileDataRepresentation()
            
            let image = UIImage(data: photoData!)
            self.capturedImageView.image = image
        }
    }
    
}







