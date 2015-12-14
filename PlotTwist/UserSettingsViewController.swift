//
//  UserSettingsViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/12/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AddressBook
import FBSDKShareKit
import MessageUI

class UserSettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FBSDKAppInviteDialogDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    let shareButton: FBSDKShareButton = FBSDKShareButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.allowsSelection = true


        // Set up CollectionView
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.collectionView.bounds.width/2 - 20, self.collectionView.bounds.height/3 - 20)
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        //        flowLayout.headerReferenceSize.height = 120
        //        flowLayout.headerReferenceSize.width = 50
        collectionView.collectionViewLayout = flowLayout

        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string:"https://itunes.apple.com/us/app/plot-twist/id1060684225?mt=8")

        shareButton.shareContent = content
        shareButton.setTitle("Share Your App", forState: .Normal)
        shareButton.frame = CGRectMake(0,0, 150, 25)
        shareButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100)
        shareButton.hidden = true
        self.view.addSubview(shareButton)

    }

    // Mark - Collection View Delegate Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UserSettingsCollectionViewCell
        //cell.backgroundColor = UIColor.whiteColor()

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.textLabel.text = "Friends"
            cell.imageView.image = UIImage(named:"F_letterSM.png")
        case 1:
            cell.textLabel.text = "Invite"
            cell.imageView.image = UIImage(named:"I_letterSM.png")
        case 2:
            cell.textLabel.text = "Help"
            cell.imageView.image = UIImage(named:"H_letterSM.png")
        case 3:
            cell.textLabel.text = "Send Feedback"
            cell.imageView.image = UIImage(named:"S_letterSM.png")
        case 4:
            cell.textLabel.text = "Share PlotTwist"
            cell.imageView.image = UIImage(named:"P_letterSM.png")
        case 5:
            cell.textLabel.text = "Logout"
            cell.imageView.image = UIImage(named:"L_letterSM.png")
        default:
            break

        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        collectionView.allowsSelection = false

        switch indexPath.row {
        case 0:
            goToFriends()
        case 1:
            inviteToPlotTwist()
        case 2:
            goToHelpPage()
        case 3:
            sendFeedback()
        case 4:
            shareAppOnFB()
        case 5:
            logout()
        default:
            collectionView.allowsSelection =  true
        }
    }


    func goToFriends() {
        performSegueWithIdentifier("ToFriendsSegue", sender: self)
        collectionView.allowsSelection = true
    }

    func goToHelpPage() {
        performSegueWithIdentifier("ToQuickTips", sender: self)
        collectionView.allowsSelection = true
    }

    func inviteToPlotTwist() {
        let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string:"https://fb.me/891999020885143")
        //content.appInvitePreviewImageURL = NSURL(string:"https://www.mydomain.com/my_invite_image.jpg")
        content.appInvitePreviewImageURL = NSURL(string: "https://github.com/Rumiya/PlotTwist/blob/master/PlotTwist/Assets.xcassets/AppIcon.appiconset/120x120.png")
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        collectionView.allowsSelection = true
    }

    func sendFeedback() {

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["app.plottwist@gmail.com"])
            mail.setSubject("PlotTwist iOS Feedback")
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            let failureAlertController = UIAlertController(title: "Email Failed", message: "Unable to open email service at this time.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            failureAlertController.addAction(okAction)
            self.presentViewController(failureAlertController, animated: true, completion: nil)
        }

         collectionView.allowsSelection = true

    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func shareAppOnFB() {
        shareButton.sendActionsForControlEvents(.TouchUpInside)
         collectionView.allowsSelection = true
    }

    func logout() {
        PTActivityIndicator.show()
        User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in

            if (error == nil) {

            // Ensures that multiple users logging in on the same device won't receive conflicting push notifications
            //UIApplication.sharedApplication().unregisterForRemoteNotifications()

            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                self.collectionView.allowsSelection = true
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("DoorLogin") as! DoorLoginViewController
                PTActivityIndicator.dismiss()
                self.presentViewController(vc, animated: true, completion: nil)
            })
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


    }

    // MARK: Error Controller
    func presentErrorWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error retrieving data", message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func onBackButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)

    }
    //FBSDKAppInviteDialogDelegate methods
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Complete invite without error")
    }

    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("Error in invite \(error)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
