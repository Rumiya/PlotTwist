//
//  StoryDetailViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class StoryDetailViewController: UIViewController {

    @IBOutlet weak var contentTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var onSettingsButtonPressed: UIButton!

    @IBAction func onSettingsButtonPressed(sender: UIButton) {
    }
    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
    }

    @IBAction func unwindToStoryDetail(sender:UIStoryboardSegue) {
        
    }
}
