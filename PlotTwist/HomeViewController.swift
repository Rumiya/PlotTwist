//
//  HomeViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/5/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {


    @IBOutlet weak var userProfileButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()

    }

    // update the home page for a curent visitor / user
    func updateUI() {

        if User.currentUser() != nil {
            let userName = User.currentUser()!.username
            let index = userName?.startIndex.advancedBy(1)
            var firstChar = userName?.substringToIndex(index!)

            firstChar = firstChar!.uppercaseString
            print(firstChar)


            if ((UIImage(named:firstChar! + "_letterSM.png")) != nil){
                
                userProfileButton.setImage(UIImage(named:firstChar! + "_letterSM.png"), forState: .Normal)

                userProfileButton.hidden = false
                print(firstChar! + "_letterSM.png")
            }

        } else {

            userProfileButton.hidden = true

        }

    }

    @IBAction func checkUserProfile(sender: UIButton) {
    }

    @IBAction func addStory(sender: UIButton) {
    }

    @IBAction func readStories(sender: UIButton) {
    }

    @IBAction func checkHistory(sender: UIButton) {
    }
 }
