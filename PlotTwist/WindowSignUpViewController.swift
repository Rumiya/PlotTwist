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

    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }

    @IBAction func onCloseButtonPressed(sender: UIButton) {
        let storyboard = self.storyboard
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("DoorLogin") as! DoorLoginViewController
      pushViewControllerLeftToRight(self, toDVC:destinationViewController)


    }
    @IBAction func onSignUpButtonPressed(sender: UIButton) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        let email = emailTextField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        // Validate the text fields
        if (username?.characters.count < 5) {
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else if (password?.characters.count < 8)
        {
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 8 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else if email!.characters.count < 8 {
            let alert = UIAlertController(title: "Invalid", message: "Please enter a valid email address", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()

            let newUser = User()

            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail

            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in

                if (error == nil){

                if let currentInstallation: PFInstallation = PFInstallation.currentInstallation(){
                    if currentInstallation.objectForKey("user") == nil {
                        currentInstallation.setObject(newUser, forKey: "user")
                        currentInstallation.saveInBackground()
                    }
                }

                let application = UIApplication.sharedApplication()
                if application.respondsToSelector("registerUserNotificationSettings:") {
                    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                }

                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                } else {
                    let alert = UIAlertController(title: "Success", message: "Signed Up", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
                            UIApplication.sharedApplication().keyWindow!.rootViewController = viewController;
                            self.presentViewController(viewController, animated: true, completion: nil)

                        })
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                } else {
                    if let error = error {
                        if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                            print("Uh oh, we couldn't even connect to the Parse Cloud!")
                        } else {
                            let errorString = error.userInfo["error"] as? NSString
                            print("Error: \(errorString)")

                        }
                        self.presentErrorWithMessage(error.userInfo["error"] as! String)
                    }
                }
            })
        }
        
    }

    // MARK: Error Controller
    func presentErrorWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error retrieving data", message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }


}
