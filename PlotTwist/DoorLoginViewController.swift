//
//  DoorLoginViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/11/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class DoorLoginViewController: UIViewController {

    @IBOutlet weak var doorView: UIView!
    @IBOutlet weak var doorKnobLoginButton: UIButton!
    @IBOutlet weak var keyHoleImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.doorKnobLoginButton.layer.shadowColor = UIColor.blackColor().CGColor
//        self.doorKnobLoginButton.layer.shadowOffset = CGSizeMake(0, 2.0);
//        self.doorKnobLoginButton.layer.shadowOpacity = 1.0;
//        self.doorKnobLoginButton.layer.shadowRadius = 0.0;
    }

    @IBAction func onFacebookButtonPressed(sender: UIButton) {
    }

    @IBAction func onDooorKnobLoginButtonPressed(sender: UIButton) {
        turnDoorKnob()
    }

    @IBAction func onForgotPasswordPressed(sender: UIButton) {
    }

    @IBAction func onSignUpButtonPressed(sender: UIButton) {
        
    }

    func turnDoorKnob() {
        UIView.animateWithDuration(2.0, animations: {
            self.doorKnobLoginButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))

            }, completion: { finished in

                self.expandCircle()
                
        })

    }

    func expandCircle(){

        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: ({
                self.keyHoleImage.layer.position = CGPointMake(self.view.bounds.width/2, self.view.bounds.height/2)
                self.keyHoleImage.transform = CGAffineTransformMakeScale(70.0, 50.0)

                //self.doorView.hidden = true
                self.view.backgroundColor = UIColor(red:0.76, green:0.91, blue:0.98, alpha:1.0)


            }), completion: { finished in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
                UIApplication.sharedApplication().keyWindow!.rootViewController = viewController;
                self.presentViewController(viewController, animated: false, completion: nil)


//                UIView.animateWithDuration(0.5, animations:{
//                    self.view.backgroundColor = UIColor(red:0.76, green:0.91, blue:0.98, alpha:1.0)
//                                        }, completion: { finished in
//
//
//                })

                
        })
    }

}