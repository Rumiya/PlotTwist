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
        presentMailboxView()
    }

    @IBAction func onSignUpButtonPressed(sender: UIButton) {
        presentWindowView()

    }

    func presentWindowView(){

        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("WindowSignUp") as! WindowSignUpViewController

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


    func presentMailboxView(){

        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("MailPassword") as! MailPasswordViewController

        let fromView:UIView = self.view
        let toView:UIView = destinationViewController.view

        let viewSize = fromView.frame

        fromView.superview?.addSubview(toView)
        toView.frame = CGRectMake(-viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height)

        UIView .animateWithDuration(1, animations: ({
            fromView.frame = CGRectMake( viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height);
            toView.frame = CGRectMake(0, viewSize.origin.y, viewSize.width, viewSize.size.height)
        }), completion: { finished in
            fromView.removeFromSuperview()
            UIApplication.sharedApplication().keyWindow!.rootViewController = destinationViewController;
            self.presentViewController(destinationViewController, animated: false, completion: nil)
        })

    }

    func turnDoorKnob() {
        UIView.animateWithDuration(1.0, animations: {
            self.doorKnobLoginButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))

            }, completion: { finished in

                self.expandCircle()
                
        })

    }

    func expandCircle(){

        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: ({
                self.keyHoleImage.layer.position = CGPointMake(self.view.bounds.width/2, self.view.bounds.height/2)
                self.keyHoleImage.transform = CGAffineTransformMakeScale(50.0, 80.0)

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
