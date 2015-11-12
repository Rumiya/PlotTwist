//
//  CusomImage.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import UIKit

func getUsernameFirstLetterImagename(name:String) -> String{

    let index = name.startIndex.advancedBy(1)
    var firstChar = name.substringToIndex(index)

    firstChar = firstChar.uppercaseString

    return firstChar + "_letterSM.png"

}

@IBDesignable class ButtonWithShadow:UIButton {

    override func awakeFromNib() {
        self.setup()
    }

    override func prepareForInterfaceBuilder() {
        self.setup()
    }

    private func setup() {
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 15.0
        //self.tintColor = UIColor.blackColor()

        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowOffset = CGSizeMake(1.0, 0.0);
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 0.0;
        self.layer.masksToBounds = false

    }

}
