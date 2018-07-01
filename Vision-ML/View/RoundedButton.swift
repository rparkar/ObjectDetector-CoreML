//
//  RoundedButton.swift
//  Vision-ML
//
//  Created by Rehan Parkar on 2018-06-30.
//  Copyright © 2018 Rehan Parkar. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
        
    }

}
