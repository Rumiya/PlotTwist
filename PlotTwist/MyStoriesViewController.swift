//
//  MyStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class MyStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var storyCount: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    
    var stories: [Story] = []
    var totalVotes: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if User.currentUser() == nil
        {
            print("Not logged in..")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })

        } else {
            print("Logged in")
                    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation.setObject(User.currentUser()!, forKey: "user")
                    currentInstallation.saveInBackground()




        }


        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {

        // TESTING PUSH NOTIFICATIONS

//        let innerQuery = User.query()
//        innerQuery!.whereKey(Constants.User.objectId, equalTo: "OQZcfCWoBp")
//
//        let query = PFInstallation.query()
//        query?.whereKey("user", matchesQuery:innerQuery!)
//
//        let data = [
//            "alert" : "Hey Lin, this is a push notification!",
//            "s" : "storyID", // Story's object id
//        ]
//
//        let push = PFPush()
//        push.setQuery(query)
//        push.setData(data)
//        push.sendPushInBackground()

         //TESTING USER SIGNUP
        /*
        let user = User()
        user.username = "linsanity"
        user.password = "myPassword"
        user.email = "linsanity@example.com"
        // other fields can be set just like with PFObject


        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {

                // Show the errorString somewhere and let the user try again.
            } else {

                // Hooray! Let them use the app now.
                PFUser.logInWithUsernameInBackground("linsanity", password:"myPassword") {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {

                        //PFPush.sendPushMessageToChannelInBackground("global", withMessage: "tesing push notifications")

                        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
                        currentInstallation.setObject(User.currentUser()!, forKey: "user")
                        currentInstallation.saveInBackground()


                        let innerQuery = User.query()
                        innerQuery!.whereKey(Constants.User.objectId, equalTo: "NxIG14eA5c")

                        let query = PFInstallation.query()
                        query?.whereKey("user", matchesQuery:innerQuery!)

                        let data = [
                            "alert" : "Testing push notifications!",
                            "s" : "storyID", // Story's object id
                        ]

                        let push = PFPush()
                        push.setQuery(query)
                        push.setData(data)
                        push.sendPushInBackground()

                        
                        self.getAllMyStories()
                        // Do stuff after successful login.
                    } else {
                        // The login failed. Check error to see why.
                    }

                }
            }
        }
*/


        //getAllMyStories()
    }

    func getAllMyStories() {

        totalVotes = 0;
        let queryStories = Story.query()
        queryStories?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)

        queryStories?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.stories = objects as! [Story]
                for story in self.stories {
                    self.totalVotes = self.totalVotes + story.voteCount
                }
                // TODO: outlet collection view
                // collectionView.reloadData()
                // also update vote count

            }
        })


        /* work on local storage later

        // First check local datastore

        let queryLocalData = Story.query()
        queryLocalData?.fromLocalDatastore()
        queryLocalData?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)

        queryLocalData?.findObjectsInBackground().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                return task
            }

            self.stories = task.result as! [Story]
            for story in self.stories {
                self.totalVotes = self.totalVotes + story.voteCount
            }
            // TODO: outlet collection view
            // collectionView.reloadData()
            // also update vote count


            // Not Check For Any New Data From Parse
            let query = Story.query()
            query?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)

            // Query for new results from the network
            query?.findObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
                return Story.unpinAllObjectsInBackgroundWithName("MyStories").continueWithSuccessBlock({ (ignored: BFTask!) -> AnyObject! in

                    // Cache new results
                    let updatedStories = task.result as! [Story]

                    if updatedStories.count != self.stories.count {
                        self.stories = updatedStories
                        for story in self.stories {
                            self.totalVotes = self.totalVotes + story.voteCount
                        }
                        // TODO: outlet collection view
                        // collectionView.reloadData()
                        // also update vote count
                    }
                    return Story.pinAllInBackground(updatedStories, withName: "MyStories")
                    
                })
            })

            return task


        })

*/

    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MyStoriesCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MyStoriesCell
        cell.backgroundColor = UIColor.blackColor()

        // Configure the cell
        return cell
    }

    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionReusableView {

            switch kind {
                //2
            case UICollectionElementKindSectionHeader:
                //3
                let headerView:MyStoriesHeader =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "Header",
                    forIndexPath: indexPath) as! MyStoriesHeader

                if User.currentUser() != nil {
                    let userName = User.currentUser()?.username

                    let index = userName?.startIndex.advancedBy(1)

                    var firstChar = userName?.substringToIndex(index!)

                    firstChar = firstChar!.uppercaseString
                    print(firstChar)
                    headerView.userImage.hidden = false
                    
                    if ((UIImage(named:firstChar! + "_letterSM.png")) != nil){
                        headerView.userImage.image = UIImage(named:firstChar! + "_letterSM.png")
                    }
                } else {
                    headerView.userImage.hidden = true
                }
                
                    
                return headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }


    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func onNotificationsButtonPressed(sender: UIBarButtonItem) {
    }

    @IBAction func unwindToMyStories(sender: UIStoryboardSegue){

    }
}
