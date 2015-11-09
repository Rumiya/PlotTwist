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