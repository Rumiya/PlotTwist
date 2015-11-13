//
//  DoorLoginViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/11/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class DoorLoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }


    @IBAction func onFacebookButtonPressed(sender: UIButton) {
        let permissions = ["public_profile", "email", "user_friends"]

        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if let user = user {

                if let currentInstallation: PFInstallation = PFInstallation.currentInstallation(){
                    if currentInstallation.objectForKey("user") == nil {
                        currentInstallation.setObject(user, forKey: "user")
                        currentInstallation.saveInBackground()
                    }
                }

                if user.isNew {
                    self.updatePFUserDetail()
                    print("User signed up and logged in through Facebook!")
                    
                    self.showMyHomeScreen()
                    
                } else {
                    print("User logged in through Facebook!")
                    self.updatePFUserDetail()
                    self.showMyHomeScreen()
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
            
        })

    }

    func showMyHomeScreen(){
        //dispatch_async(dispatch_get_main_queue(), { () -> Void in

            self.turnDoorKnob()

//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
//            UIApplication.sharedApplication().keyWindow!.rootViewController = viewController;
//
//            self.presentViewController(viewController, animated: true, completion: nil)
        //})
    }

    func updatePFUserDetail() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, friends"]).startWithCompletionHandler({ (connection, result, error) in
                if (error != nil) { return }
                if let fbUser = result as? NSDictionary {
                    let email = fbUser.objectForKey("email") as? String
                    let username = fbUser.objectForKey("name") as? String
                    // let facebookID:String = (fbUser.objectForKey("id") as? String)!

                    let user = User.currentUser()
                    user!.email = email
                    user!.username = username
                    user!.saveInBackground()

                }
            })
        }
    }


    @IBAction func onDooorKnobLoginButtonPressed(sender: UIButton) {

        let username = self.usernameTextField.text
        let password = passwordTextField.text

        if (username?.characters.count < 5) {
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else if (password?.characters.count < 8)
        {
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 8 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()

            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in

                if let currentInstallation: PFInstallation = PFInstallation.currentInstallation(){
                    if currentInstallation.objectForKey("user") == nil {
                        currentInstallation.setObject(user!, forKey: "user")
                        currentInstallation.saveInBackground()
                    }
                }
                
                // Stop the spinner
                spinner.stopAnimating()

                if ((user) != nil) {
                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        self.showMyHomeScreen()
                    })

                } else {
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }

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

        pushViewControllerRightToLeft(self, toDVC: destinationViewController)
    }


    func presentMailboxView(){

        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("MailPassword") as! MailPasswordViewController

        pushViewControllerLeftToRight(self, toDVC: destinationViewController)

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
