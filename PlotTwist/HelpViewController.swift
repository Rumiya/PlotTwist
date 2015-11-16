//
//  HelpViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/14/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCloseButtonPressed(sender: UIButton) {
        func goBackHome(){

            // not working
             performSegueWithIdentifier("unwindToHomeScreen", sender: self)

            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
            UIApplication.sharedApplication().keyWindow!.rootViewController = viewController;
            self.presentViewController(viewController, animated: true, completion: nil)

        }

    }

    @IBAction func onDoneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
