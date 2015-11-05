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

class MyStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NewStoryDelegate, DeleteStoryDelegate {
 
    @IBOutlet weak var collectionView: UICollectionView!

    var stories: [Story] = []
    var totalVotes: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if User.currentUser() == nil
        {
            print("Not logged in..")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })

        } else {
            print("Logged in")
            updateBadges()
            getAllMyStories()
        }

        // Set up CollectionView 
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(view.bounds.width/3 - 10, view.bounds.height/3 - 10)
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        flowLayout.headerReferenceSize.height = 120
        flowLayout.headerReferenceSize.width = 50

        collectionView.collectionViewLayout = flowLayout


    }

    override func viewWillAppear(animated: Bool) {
        //getAllMyStories()
    }

    func updateBadges() {
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setObject(User.currentUser()!, forKey: "user")
        currentInstallation.saveInBackground()

        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        if currentInstallation.badge > 0 {
            tabItem.badgeValue = "\(currentInstallation.badge)"
        }
    }

    func didAddNewStory(newStory: Story, nextAuthor: User) {
        newStory.currentAuthor = nextAuthor
        newStory.saveInBackground()
        getAllMyStories()
    }

    func didDeleteStory() {
        getAllMyStories()
    }
    
    // MARK - Parse Queries
    func getAllMyStories() {

        totalVotes = 0;
        let queryStories = Story.query()
        queryStories?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)
        queryStories?.whereKeyExists(Constants.Story.objectId)

        queryStories?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.stories = objects as! [Story]
                for story in self.stories {
                    self.totalVotes = self.totalVotes + story.voteCount
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
            }
        })
    }


    // Mark - Collection View Delegate Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stories.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MyStoriesCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MyStoriesCell
        cell.backgroundColor = UIColor.whiteColor()

        let story: Story = self.stories[indexPath.item]

        if (story.isPublished){
            cell.pageCount.hidden = true
            cell.backgroundColor = UIColor(red:0.77, green:0.94, blue:0.71, alpha:1.0)
        } else {
            cell.pageCount.hidden = false
            cell.pageCount.text = "\(story.pageCount)"
            cell.backgroundColor = UIColor(red:0.82, green:0.78, blue:0.91, alpha:1.0)
        }
        cell.storyTitle.text = story.storyTitle
        cell.storyTitle.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2));


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
                    let userName = User.currentUser()!.username

                    let index = userName?.startIndex.advancedBy(1)

                    var firstChar = userName?.substringToIndex(index!)

                    firstChar = firstChar!.uppercaseString
                    print(firstChar)
                    headerView.userImage.hidden = false

                    if ((UIImage(named:firstChar! + "_letterSM.png")) != nil){
                        headerView.userImage.image = UIImage(named:firstChar! + "_letterSM.png")
                    }
                    headerView.storyCountLabel.text = "Stories: \(self.stories.count)"
                    headerView.voteCountLabel.text = "Upvotes: \(self.totalVotes)"
                    headerView.usernameLabel.text = String(userName!.characters.dropFirst())
                } else {
                    headerView.userImage.hidden = true
                    headerView.usernameLabel.hidden = true
                    
                }

                return headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToStoryDetailSegue" {
            let vc = segue.destinationViewController as! StoryDetailViewController
            let selectedCell = sender as! MyStoriesCell
            let indexPath = collectionView.indexPathForCell(selectedCell)
            vc.story = stories[(indexPath?.item)!]
            vc.delegate = self
        } else if segue.identifier == "ToAddStorySegue" {
            let vc = segue.destinationViewController as! AddStoryViewController
            vc.delegate = self
        }
    }

    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func onNotificationsButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func unwindToMyStories(sender: UIStoryboardSegue){
        
    }
}
