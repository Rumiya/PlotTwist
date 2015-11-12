//
//  WindowSignUpViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/12/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class WindowSignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onCloseButtonPressed(sender: UIButton) {
        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("DoorLogin") as! DoorLoginViewController
      pushViewControllerLeftToRight(self, toDVC:destinationViewController)


    }
    @IBAction func onSignUpButtonPressed(sender: UIButton) {
    }
}
