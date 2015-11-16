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
    var storyLastPage: [Page]=[]
    var friendBalloonEndPoint: CGPoint = CGPointMake(0,0)
    var helpImageName:String = ""
    let defaults = NSUserDefaults.standardUserDefaults()
//    var storyLastPage = [Story]()

    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var cloudsImage: UIImageView!
    @IBOutlet weak var friendButton: UIButton!

    @IBOutlet weak var crayonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var glassesBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var outboxBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var outboxLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var glassesLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var airBalloonTopSpace: NSLayoutConstraint!
    @IBOutlet weak var airBalloonHeight: NSLayoutConstraint!
    @IBOutlet weak var inboxTopSpaceToUser: NSLayoutConstraint!

    @IBOutlet weak var helpOverlayImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.performSegueWithIdentifier("ToHelpScreenStart", sender: self)



        updateUI()
    }

    override func viewWillAppear(animated: Bool) {

        // detect screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        // let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        if screenHeight == 480 {
            crayonBottomSpace.constant = 25
            glassesBottomSpace.constant = 25
            outboxBottomSpace.constant = 25
            outboxLeadingSpace.constant = 50
            glassesLeadingSpace.constant = 50
            airBalloonTopSpace.constant = 25
            airBalloonHeight.constant = 310
            inboxTopSpaceToUser.constant = 90
            self.friendBalloonEndPoint = CGPointMake(270, 189)

        } else if screenHeight == 568 {

            self.friendBalloonEndPoint = CGPointMake(270, 189)

        } else if screenHeight == 667 {

            self.friendBalloonEndPoint = CGPointMake(310, 230)

        } else if screenHeight == 736 {

            self.friendBalloonEndPoint = CGPointMake(350, 250)

        } else {
            self.friendBalloonEndPoint = CGPointMake(368, 219)
        }

        // check if user has viewed "Start Read" help overlay
        let hasViewedStartRead = self.defaults.boolForKey("hasViewedStartRead")

        // check if user has viewed "User Settings" help overlay
        let hasViewedUserSettings = self.defaults.boolForKey("hasViewedUserSettings")

        // display quick tips to start
        if hasViewedStartRead == false {

            self.helpOverlayImage.image = UIImage(named: "startRead")
            self.helpOverlayImage.hidden = false
            self.helpImageName = "startRead"

        } else if hasViewedUserSettings == false {

            self.helpOverlayImage.image = UIImage(named: "userSettings")
            self.helpOverlayImage.hidden = false
            self.helpImageName = "userSettings"

        }

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

        // set unhide friend's air balloon
        self.friendButton.hidden = false

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: self.view.bounds.width,y: 219))
        //path.addCurveToPoint(CGPoint(x: 270, y: 189), controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))
        path.addCurveToPoint(self.friendBalloonEndPoint, controlPoint1: CGPoint(x: 136, y: 373), controlPoint2: CGPoint(x: 178, y: 110))

       // path.moveToPoint(self.friendStartPoint!)
        
        let anim = CAKeyframeAnimation(keyPath: "position")

        // set the animations path to our bezier curve
        anim.path = path.CGPath

        //anim.repeatCount = 1
        anim.duration = 5.5
        anim.fillMode = kCAFillModeForwards
        anim.removedOnCompletion = false

        // we add the animation to the squares 'layer' property
        self.friendButton.layer.addAnimation(anim, forKey: "animate position along path")
        //self.friendButton.layer.position = CGPointMake(270, 189)
        self.friendButton.layer.position = self.friendBalloonEndPoint


       // fadeOutLayerAnimation(self.friendButton.layer, beginTime: 5.0)

        // display help overlay if help image is hidden
        if self.helpOverlayImage.hidden {
            // check if user has viewed "a New Story" help overlay
            let hasViewedFriendRequest = self.defaults.boolForKey("hasViewedFriendRequest")
            // display quick tips to start
            if hasViewedFriendRequest == false {
                self.helpOverlayImage.image = UIImage(named: "friendRequest")
                self.helpOverlayImage.hidden = false
                self.helpImageName = "friendRequest"
            }
        }

        
    }

    func fadeOutLayerAnimation(layer: CALayer!, beginTime: NSTimeInterval) {

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 2
        fadeAnimation.beginTime = beginTime
        fadeAnimation.repeatCount = Float(Int.max)

        layer.opacity = 0.5
        layer.addAnimation(fadeAnimation, forKey: "FadeAnimation")

        // display help overlay if help image is hidden
        if self.helpOverlayImage.hidden {
            // check if user has viewed "a New Story" help overlay
            let hasViewedNewStory = self.defaults.boolForKey("hasViewedNewStory")
            // display quick tips to start
            if hasViewedNewStory == false {
                self.helpOverlayImage.image = UIImage(named: "aNewStory")
                self.helpOverlayImage.hidden = false
                self.helpImageName = "aNewStory"
            }
        }


    }


    // update the home page for a curent visitor / user
    func updateUI() {

        passCloudsByAnimation()
        //self.friendAppearingAnimation()


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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        // dismiss help overlay
        if !self.helpOverlayImage.hidden {

            switch self.helpImageName {
            case "startRead":
                self.defaults.setBool(true, forKey: "hasViewedStartRead")

            case "aNewStory":
                self.defaults.setBool(true, forKey: "hasViewedNewStory")

            case "friendRequest":
                self.defaults.setBool(true, forKey: "hasViewedFriendRequest")

            case "userSettings":
                self.defaults.setBool(true, forKey: "hasViewedUserSettings")

            case "sentStories":
                self.defaults.setBool(true, forKey: "hasViewedSentStories")

            default:
                self.helpOverlayImage.hidden = true
            }

            self.helpOverlayImage.hidden = true
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
                    self.fadeOutLayerAnimation(self.notificationButton.layer, beginTime: 4.0)

                    // Notification Counts are replaced with the envelope image
                    //self.notificationButton.setTitle("\(counts)", forState: .Normal)
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

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if counts == 0 {
                    self.friendButton.hidden = true
                } else {
                    self.friendButton.hidden = false
                    self.friendAppearingAnimation()
                }
            })
        })
    }

    func didAddNewPage() {
        getNotificationCount()
    }

    func didAcceptFriend() {
        getNotificationCount()
    }

    @IBAction func onNotificationButtonPressed(sender: UIButton) {

        let userQuery = User.query()
        userQuery?.whereKey(Constants.User.objectId, equalTo: (User.currentUser()?.objectId)!)

        let storyQuery = Story.query()
        storyQuery?.whereKey(Constants.Story.allAuthors, matchesQuery: userQuery!)

        storyQuery?.whereKey(Constants.Story.isPublished, equalTo: false)
        storyQuery?.whereKey(Constants.Story.currentAuthor, equalTo: User.currentUser()!)
        storyQuery?.includeKey(Constants.Story.pages)

//        storyQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
//            if objects != nil {
//                self.story = objects!.first as! Story
//                self.performSegueWithIdentifier("ToNewPageSegue", sender: sender)
//                
//            }
//
//        })
        
        storyQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if objects != nil {
                
                let stories = objects as! [Story]
                self.storyLastPage = []
                for object in stories {
                    
                    
                    self.storyLastPage.append(object.pages.last!)
                    
                }
                
                if self.storyLastPage.count == stories.count {
                  
                self.performSegueWithIdentifier("ToNewPageSegue", sender: sender)
                   
                }
            }
        })
    }

    @IBAction func onFriendButtonPressed(sender: UIButton) {
        fadeInFriendBalloonAnimation()
    }

    func fadeInFriendBalloonAnimation() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.friendButton.layer.opacity = 1.0

            }, completion: nil)
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
            let vc = segue.destinationViewController as! InboxViewController
            self.storyLastPage.sortInPlace({ $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending })
          vc.incomingStoryPageArray = self.storyLastPage


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

        NSTimer.scheduledTimerWithTimeInterval(0.7, target: self,
            selector: "viewSentStoriesTip",
            userInfo: nil, repeats: false)
        
    }

    func viewSentStoriesTip(){

        // check if user has viewed "Sent Stories" help overlay
        let hasViewedSentStories = self.defaults.boolForKey("hasViewedSentStories")

        // display a quick tip
        if hasViewedSentStories == false {

            self.helpOverlayImage.image = UIImage(named: "sentStories")
            self.helpOverlayImage.hidden = false
            self.helpImageName = "sentStories"

        }
    }

    
}
