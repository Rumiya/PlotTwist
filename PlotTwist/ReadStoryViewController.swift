//
//  ReadStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ReadStoryViewController: UIViewController {

    @IBOutlet weak var content: UILabel!

    var story: Story?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.content.text = story?.storyTitle
    }

}
