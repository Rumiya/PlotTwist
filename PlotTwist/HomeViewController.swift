//
//  HomeViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/5/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, DecrementNotificationsCountDelegate, FriendListDelegate {

    var story = Story()
    var friendStartPoint: CGPoint?
    var cloudsEndPoint: CGPoint?

    @IBOutlet weak var userProfileButton: UIButton!

    @IBOutlet weak var notificationButton: UIButton!

    @IBOutlet weak var cloudsImage: UIImageView!

    @IBOutlet weak var friendButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func passCloudsByAnimation(){
        // set clouds position
        self.cloudsImage.layer.position = CGPoint(x:0 - self.view.bounds.width/2, y:view.bounds.height/3)
        self.cloudsImage.hidden = false
        //  self.cloudsStartPoint = self.cloudsImage.layer.position

        UIView.animateWithDuration(6, delay: 0,
            options: UIViewAnimationOptions.CurveLinear, animations: {

                self.cloudsImage.layer.position.x = self.view.bounds.width
        }, completion: nil)

    }

    func friendAppearingAnimation(){

        // set friend's air balloon position
        self.friendButton.layer.position = CGPoint(x: self.view.bounds.width/3, y: self.view.bounds.height/2.5)
        self.friendStartPoint = self.friendButton.layer.position

        self.friendButton.hidden = false

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: self.view.bounds.width,y: 239))
        path.addCurveToPoint(CGPoint(x: 301, y: 239), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))

        path.moveToPoint(self.friendStartPoint!)
        
        let anim = CAKeyframeAnimation(keyPath: "position")

        // set the animations path to our bezier curve
        anim.path = path.CGPath

        anim.repeatCount = 1
        anim.duration = 5.0
        anim.removedOnCompletion = false


        // we add the animation to the squares 'layer' property
        self.friendButton.layer.addAnimation(anim, forKey: "animate position along path")
        //self.friendButton.layer.position = CGPoint(x: 136, y: 373)

    }


    // update the home page for a curent visitor / user
    func updateUI() {

        passCloudsByAnimation()
        self.friendAppearingAnimation()


        if User.currentUser() != nil {
            let userName = User.currentUser()!.username

            let usernameImage = getUsernameFirstLetterImagename(userName!)

            if ((UIImage(named:usernameImage)) != nil){
                
                userProfileButton.setImage(UIImage(named:usernameImage), forState: .Normal)

                userProfileButton.hidden = false

                // Called from App Delegate didBecomeActive
                getNotificationCount()
            }

        } else {
            userProfileButton.hidden = true
        }
    }

    func getNotificationCount(){

        let userQuery = User.query()
        userQuery?.whereKey(Constants.User.objectId, equalTo: (User.currentUser()?.objectId)!)

        let storyQuery = Story.query()
        storyQuery?.whereKey(Constants.Story.allAuthors, matchesQuery: userQuery!)

        storyQuery?.whereKey(Constants.Story.isPublished, equalTo: false)
        storyQuery?.whereKey(Constants.Story.currentAuthor, equalTo: User.currentUser()!)

        storyQuery?.countObjectsInBackgroundWithBlock({ (counts: Int32, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if counts == 0 {
                    self.notificationButton.hidden = true
                } else {
                    self.notificationButton.hidden = false
                    self.notificationButton.setTitle("\(counts)", forState: .Normal)
                }
            })
        })

        let friendIncomingQuery = Activity.query()
        friendIncomingQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)
        friendIncomingQuery?.whereKey(Constants.Activity.requestType, equalTo: Constants.Activity.Requests.outgoing)
        friendIncomingQuery?.whereKey(Constants.Activity.type, equalTo: Constants.Activity.Type.friend)
        friendIncomingQuery?.includeKey(Constants.Activity.fromUser)
        friendIncomingQuery?.includeKey(Constants.Activity.toUser)
        friendIncomingQuery?.countObjectsInBackgroundWithBlock({ (counts: Int32, error: NSError?) -> Void in
            // TODO: uncomment this after merge

//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if counts == 0 {
//                    self.friendButton.hidden = true
//                } else {
//                    self.friendButton.hidden = false
//                    self.friendAppearingAnimation()
//                }
//            })

        })

    }

    func didAddNewPage() {
        getNotificationCount()
    }

    func didAcceptFriend() {
        getNotificationCount()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onNotificationButtonPressed(sender: UIButton) {

        let userQuery = User.query()
        userQuery?.whereKey(Constants.User.objectId, equalTo: (User.currentUser()?.objectId)!)

        let storyQuery = Story.query()
        storyQuery?.whereKey(Constants.Story.allAuthors, matchesQuery: userQuery!)

        storyQuery?.whereKey(Constants.Story.isPublished, equalTo: false)
        storyQuery?.whereKey(Constants.Story.currentAuthor, equalTo: User.currentUser()!)

        storyQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if objects != nil {
                self.story = objects!.first as! Story
                self.performSegueWithIdentifier("ToNewPageSegue", sender: sender)
            }

        })
        
    }

    @IBAction func checkUserProfile(sender: UIButton) {
    }

    @IBAction func addStory(sender: UIButton) {
        self.performSegueWithIdentifier("ToNewStorySegue", sender: self)
    }

    @IBAction func readStories(sender: UIButton) {
    }

    @IBAction func checkHistory(sender: UIButton) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToNewPageSegue"{
            let vc = segue.destinationViewController as! ComposeViewController
            vc.story = story
            vc.isNewStory = false
            vc.homeVC = self

        } else if segue.identifier == "ToNewStorySegue"{
            let vc = segue.destinationViewController as! ComposeViewController
            vc.story = Story()
            vc.isNewStory = true
            vc.homeVC = self

        } else if segue.identifier == "ToFriendsSegue" {
            let vc = segue.destinationViewController as! FriendsViewController
            vc.delegate = self
        }
    }

    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {
        
    }
    
}
