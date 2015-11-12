//
//  MailPasswordViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/11/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class MailPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func onResetButtonPressed(sender: UIButton) {

    }

    @IBAction func onCloseButtonPressed(sender: UIButton) {

        presentDoorView()
    }

    func presentDoorView(){

        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("DoorLogin") as! DoorLoginViewController

        pushViewControllerRightToLeft(self, toDVC: destinationViewController)

    }

}
