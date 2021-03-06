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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func onResetButtonPressed(sender: UIButton) {
        let email = emailTextField.text
        
        let userQuery: PFQuery = User.query()!
        userQuery.whereKey("email", equalTo: email!)
        
         userQuery.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
            let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if email?.characters.count == 0 {
                let alert = UIAlertController (title: "Error", message: "The text field is blank.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                 }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }

        
            else if ((object?.isEqual(email)) != nil){
                print("great you found me")
                //if valid pop reset password request
                
                // Send a request to reset a password
                User.requestPasswordResetForEmailInBackground(finalEmail)
                
                let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + finalEmail + ".", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                    self.presentDoorView()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                //if email not found  pop error
                let alert = UIAlertController (title: "Error", message: finalEmail + " email is not found " + ".", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) -> Void in
                  
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
                print("email not found")
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
        
        }
        
        
//        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
//            print(objects)
//        }
       
  
        
    }

    // MARK: Error Controller
    func presentErrorWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error retrieving data", message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
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
