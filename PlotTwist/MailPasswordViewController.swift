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

        let fromView:UIView = self.view
        let toView:UIView = destinationViewController.view

        let viewSize = fromView.frame

        fromView.superview?.addSubview(toView)
        toView.frame = CGRectMake(viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height)

        UIView .animateWithDuration(1, animations: ({
            fromView.frame = CGRectMake( -viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height);
            toView.frame = CGRectMake(0, viewSize.origin.y, viewSize.width, viewSize.size.height)
        }), completion: { finished in
            fromView.removeFromSuperview()
            UIApplication.sharedApplication().keyWindow!.rootViewController = destinationViewController;
            self.presentViewController(destinationViewController, animated: false, completion: nil)

        })
        
    }

}
