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

class UserSettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FBSDKAppInviteDialogDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

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
        content.contentURL = NSURL(string:"https://itunes.apple.com/us/app/craftsbury-skiing/id782983949?mt=8")
        let shareButton: FBSDKShareButton = FBSDKShareButton()
        shareButton.shareContent = content
        shareButton.setTitle("Share Your App", forState: .Normal)
        shareButton.frame = CGRectMake(0,0, 150, 25)
        shareButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 100)
        self.view.addSubview(shareButton)

    }

    // Mark - Collection View Delegate Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
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
            logout()
        default:
            collectionView.allowsSelection = true
        }
    }


    func goToFriends() {
        performSegueWithIdentifier("ToFriendsSegue", sender: self)
        collectionView.allowsSelection = true
    }

    func inviteToPlotTwist() {
        let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string:"https://www.mydomain.com/myapplink")
        content.appInvitePreviewImageURL = NSURL(string:"https://www.mydomain.com/my_invite_image.jpg")
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        collectionView.allowsSelection = true
    }

    func logout() {
        User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in

            // Ensures that multiple users logging in on the same device won't receive conflicting push notifications
            UIApplication.sharedApplication().unregisterForRemoteNotifications()

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.allowsSelection = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(vc, animated: true, completion: nil)


            })
        }
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
