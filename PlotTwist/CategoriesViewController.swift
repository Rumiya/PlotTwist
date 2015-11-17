//
//  CategoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var storiesToSend: [Story] = []

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

    }

    // Mark - Collection View Delegate Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CategoriesCollectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CategoriesCollectionViewCell
        //cell.backgroundColor = UIColor.whiteColor()

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.categoryLabel.text = "All"
            cell.categoryImage.image = UIImage(named:"A_letterSM.png")
        case 1:
            cell.categoryLabel.text = "Popular"
            cell.categoryImage.image = UIImage(named:"P_letterSM.png")
        case 2:
            cell.categoryLabel.text = "Friends"
            cell.categoryImage.image = UIImage(named:"F_letterSM.png")
        case 3:
            cell.categoryLabel.text = "iPublished"
            cell.categoryImage.image = UIImage(named:"I_letterSM.png")
        case 4:
            cell.categoryLabel.text = "Staff Picks"
            cell.categoryImage.image = UIImage(named:"S_letterSM.png")
        case 5:
            cell.categoryLabel.text = "Newbies"
            cell.categoryImage.image = UIImage(named:"N_letterSM.png")
        default:
            cell.categoryLabel.text = "All"
            cell.categoryImage.image = UIImage(named:"A_letterSM.png")

        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        collectionView.allowsSelection = false

        PTActivityIndicator.show()

        switch indexPath.row {
        case 0:
            readAllStories()
        case 1:
            readAllStories()
        case 2:
            readFriendsStories()
        case 3:
            readMyPublishedStories()
        case 4:
            readAllStories()
        case 5:
            readNewbyStories()
        default:
            readAllStories()
        }
    }

    func readAllStories(){

        let queryPublished = Story.query()
        queryPublished?.whereKey(Constants.Story.isPublished, equalTo: true)
        queryPublished?.whereKeyExists(Constants.Story.objectId)
        queryPublished?.includeKey(Constants.Story.pages)
        queryPublished?.includeKey(Constants.Story.mainAuthor)
        queryPublished?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.storiesToSend = objects as! [Story]
                self.performSegueWithIdentifier("ToListOfStoriesSegue", sender: self)

            self.collectionView.allowsSelection = true
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


    func readFriendsStories(){

        var friends: [User] = []
        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: (User.currentUser()?.objectId)!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let tempUsers = objects as! [User]
                //self.users = objects as! [User]
                var count = 0;

                for user in tempUsers {

                    let friendOutgoingQuery = Activity.query()
                    friendOutgoingQuery?.whereKey(Constants.Activity.fromUser, equalTo: User.currentUser()!)
                    friendOutgoingQuery?.whereKey(Constants.Activity.toUser, equalTo: user)

                    let friendIncomingQuery = Activity.query()
                    friendIncomingQuery?.whereKey(Constants.Activity.fromUser, equalTo: user)
                    friendIncomingQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)

                    let allFriendQuery = PFQuery.orQueryWithSubqueries([friendOutgoingQuery!, friendIncomingQuery!])
                    allFriendQuery.whereKey(Constants.Activity.type, equalTo: Constants.Activity.Type.friend)
                    allFriendQuery.whereKey(Constants.Activity.requestType, equalTo: Constants.Activity.Requests.confirmed)
                    allFriendQuery.includeKey(Constants.Activity.fromUser)
                    allFriendQuery.includeKey(Constants.Activity.toUser)
                    allFriendQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in

                        let activities = objects as! [Activity]

                        for activity in activities {
                            if activity.toUser.objectId != User.currentUser()?.objectId {
                                friends.append(activity.toUser)
                            }
                            if activity.fromUser.objectId != User.currentUser()?.objectId {
                                friends.append(activity.fromUser)
                            }
                        }

                        count = count + 1
                        if (count == tempUsers.count) {
                            let storyQuery = Story.query()
                            storyQuery?.whereKey(Constants.Story.allAuthors, containedIn: friends)
                            storyQuery?.includeKey(Constants.Story.mainAuthor)
                            storyQuery?.includeKey(Constants.Story.pages)
                            storyQuery?.whereKey(Constants.Story.isPublished, equalTo: true)
                            storyQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                                self.storiesToSend = objects as! [Story]
                                self.performSegueWithIdentifier("ToListOfStoriesSegue", sender: self)

                            })
                        }
                    }
                }
            } else {
                print("error retrieving")
                if let error = error {
                    if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                        print("Uh oh, we couldn't even connect to the Parse Cloud!")
                    } else {
                        let errorString = error.userInfo["error"] as? NSString
                        print("Error: \(errorString)")

                    }
                    self.presentErrorWithMessage(error.userInfo["error"] as! String)                }
            }

            self.collectionView.allowsSelection = true
        })
    }



    func readNewbyStories() {

        let today = NSDate()

        let lastWeek = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day,
            value: -7,
            toDate: today,
            options: NSCalendarOptions(rawValue: 0))

        let newbyAuthorQuery = User.query()
        newbyAuthorQuery?.includeKey(Constants.User.authoredStories)
        newbyAuthorQuery?.whereKey(Constants.User.createdAt, greaterThanOrEqualTo: lastWeek!)

        let storyQuery = Story.query()
        storyQuery?.whereKey(Constants.Story.mainAuthor, matchesQuery: newbyAuthorQuery!)
        storyQuery?.whereKey(Constants.Story.isPublished, equalTo: true)
        storyQuery?.includeKey(Constants.Story.pages)
        storyQuery?.whereKeyExists(Constants.Story.objectId)
        storyQuery?.includeKey(Constants.Story.mainAuthor)
        storyQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
            self.storiesToSend = objects as! [Story]
            self.performSegueWithIdentifier("ToListOfStoriesSegue", sender: self)

            self.collectionView.allowsSelection = true
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

    func readMyPublishedStories(){

        let queryPublished = Story.query()
        queryPublished?.whereKey(Constants.Story.isPublished, equalTo: true)
        queryPublished?.whereKeyExists(Constants.Story.objectId)
        queryPublished?.includeKey(Constants.Story.pages)
        queryPublished?.includeKey(Constants.Story.mainAuthor)
        queryPublished?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)
        queryPublished?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if (error ==  nil) {
                self.storiesToSend = objects as! [Story]
                self.performSegueWithIdentifier("ToListOfStoriesSegue", sender: self)

            self.collectionView.allowsSelection = true
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

    // MARK: Error Controller
    func presentErrorWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error retrieving data", message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    //MARK: Navigtion Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToListOfStoriesSegue"{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                PTActivityIndicator.dismiss()
            })
            let vc = segue.destinationViewController as! ListOfStoriesViewController
            vc.stories = self.storiesToSend
        }
    }

    // MARK: IBActions
    @IBAction func unwindToCategories(segue:UIStoryboardSegue) {
        
    }
    
    
}
