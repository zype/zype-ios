//
//  BottomBorderTextField.swift
//
//  Created by PJ Vea on 10/22/15.
//  Copyright © 2015 Zype. All rights reserved.
//

import UIKit

@objc class BottomBorderTextField: UITextField
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setupDefaultAppearence()
    }
    
    func setupDefaultAppearence()
    {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor(red:0.64, green:0.68, blue:0.70, alpha:1.0).cgColor
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5)
        self.layer.addSublayer(bottomBorder)
    }

}
