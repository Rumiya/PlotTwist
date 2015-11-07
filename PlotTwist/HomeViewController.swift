//
//  HomeViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/5/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, DecrementNotificationsCountDelegate {

    var story: Story?
    var cloudsStartPoint: CGPoint?
    var cloudsEndPoint: CGPoint?

    @IBOutlet weak var userProfileButton: UIButton!

    @IBOutlet weak var notificationButton: UIButton!

    @IBOutlet weak var cloudsImage: UIImageView!

    

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()

    }

    func passCloudsByAnimation(){

        UIView.animateWithDuration(6, delay: 0,
            options: UIViewAnimationOptions.CurveLinear, animations: {

                self.cloudsImage.layer.position.x = self.view.bounds.width
        }, completion: nil)

    }

    // update the home page for a curent visitor / user
    func updateUI() {

        self.cloudsImage.layer.position = CGPoint(x:0 - self.view.bounds.width/2, y:view.bounds.height/3)
        self.cloudsImage.hidden = false
        self.cloudsStartPoint = self.cloudsImage.layer.position


        passCloudsByAnimation()

        if User.currentUser() != nil {
            let userName = User.currentUser()!.username
            let index = userName?.startIndex.advancedBy(1)
            var firstChar = userName?.substringToIndex(index!)

            firstChar = firstChar!.uppercaseString
            print(firstChar)


            if ((UIImage(named:firstChar! + "_letterSM.png")) != nil){
                
                userProfileButton.setImage(UIImage(named:firstChar! + "_letterSM.png"), forState: .Normal)

                userProfileButton.hidden = false
                print(firstChar! + "_letterSM.png")

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
                    self.notificationButton.titleLabel?.text = "\(counts)"
                }
            })
        })
    }

    func didAddNewPage() {
        getNotificationCount()
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
                self.story = objects!.first as? Story
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
        }
        
    }

    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {

    }

 }
