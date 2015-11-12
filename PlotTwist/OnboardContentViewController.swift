//
//  OnboardContentViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/12/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class OnboardContentViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    var pageIndex: Int?
    var titleText : String!
    var imageName : String!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = UIImage(named: imageName)
        self.textLabel.text = self.titleText
    }
    
}
