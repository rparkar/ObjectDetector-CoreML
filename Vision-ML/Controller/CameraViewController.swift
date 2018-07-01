//
//  CameraViewController.swift
//  Vision-ML
//
//  Created by Rehan Parkar on 2018-06-30.
//  Copyright © 2018 Rehan Parkar. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    //outlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var roundedLabelsView: RoundedShadowView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

