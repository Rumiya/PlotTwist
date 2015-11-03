//
//  LoginViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {
    @IBOutlet weak var loginWithFBbutton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        //loginWithFBbutton.readPermissions = ["public_profile", "email", "user_friends"]
       // loginWithFBbutton.delegate = self
    }
    @IBAction func onFBloginButtonPressed(sender: UIButton) {

        let permissions = ["public_profile", "email", "user_friends"]

        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {

                    print("User signed up and logged in through Facebook!")

//                    // Create the AlertController
//                    let actionSheetController: UIAlertController = UIAlertController(title: "New User", message: "Create a username for your new Plot Twist account." , preferredStyle: .Alert)
//
//                    // Add a text field
//                    actionSheetController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
//                        //TextField configuration
//                        textField.textColor = UIColor.blueColor()
//
//                    })
//
//                    //Create and add the Done action
//                    let okAction: UIAlertAction = UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in
//                        // add a userName
//                        let enteredUserName = actionSheetController.textFields![0] as UITextField
//                        let user = User()
//                        user.username = enteredUserName.text
//                        user.saveInBackground()
//                        self.updatePFUserDetail()
//                        self.showMyStories()
//                    })
//                    actionSheetController.addAction(okAction)
//
//                    // Present the AlertControler
//                    self.presentViewController(actionSheetController, animated: true, completion: nil)

                    self.showMyStories()

                } else {
                    print("User logged in through Facebook!")
                    self.showMyStories()
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }

        })
     }

    @IBAction func onLoginButtonPressed(sender: UIButton) {
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

                // Stop the spinner
                spinner.stopAnimating()

                if ((user) != nil) {
                    let alert = UIAlertController(title: "Success", message: "Logged In", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    self.showMyStories()
                } else {
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }

    }

    func showMyStories()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyStories")
            self.presentViewController(viewController, animated: true, completion: nil)
        })

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

    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
}