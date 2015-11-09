//
//  UserStatisticsViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/6/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AddressBook
import FBSDKShareKit


class UserStatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKAppInviteDialogDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //share button
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string:"https://itunes.apple.com/us/app/craftsbury-skiing/id782983949?mt=8")
        let shareButton: FBSDKShareButton = FBSDKShareButton()
        shareButton.shareContent = content
        shareButton.setTitle("Share Your App", forState: .Normal)
        shareButton.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 150) * 0.5, 200, 150, 25)
        shareButton.center = CGPointMake(200, 400)
        self.view.addSubview(shareButton)
    }
    
    
    @IBAction func inviteToInstallAppButton(sender: UIButton) {
        let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string:"https://www.mydomain.com/myapplink")
        content.appInvitePreviewImageURL = NSURL(string:"https://www.mydomain.com/my_invite_image.jpg")
        
      
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        
        
    }
    //FBSDKAppInviteDialogDelegate methods
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Complete invite without error")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("Error in invite \(error)")
    }
    
    @IBOutlet weak var tableView: UITableView!

 

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
    NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell",
    forIndexPath: indexPath) as! UserStatisticsTableViewCell

    // Configure the cell...
    switch indexPath.row {
    case 0:
        cell.typeLabel.text = "My Published Stories"
        cell.countLabel.text = ""
    case 1:
        cell.typeLabel.text = "Still Twisting"
        cell.countLabel.text = ""
    case 2:
        cell.typeLabel.text = "Co-authored Stories"
        cell.countLabel.text = ""
    case 3:
        cell.typeLabel.text = ""
        cell.countLabel.text = ""
    default:
        cell.typeLabel.text = ""
        cell.countLabel.text = ""
    }

        return cell
    }

    @IBAction func onSettingsButtonPressed(sender: UIButton) {
    }

    @IBAction func onLogOutButtonPressed(sender: UIButton) {

    User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
    dispatch_async(dispatch_get_main_queue(), { () -> Void in

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        self.presentViewController(vc, animated: true, completion: nil)

        })
    }

    }

 }
