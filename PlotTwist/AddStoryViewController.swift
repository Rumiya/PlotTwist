//
//  AddStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class AddStoryViewController: UIViewController {

    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!

    @IBOutlet weak var starterPickerView: UIPickerView!

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var onSaveButtonPressed: UIBarButtonItem!

    @IBOutlet weak var onCancelButtonPressed: UIBarButtonItem!
}
