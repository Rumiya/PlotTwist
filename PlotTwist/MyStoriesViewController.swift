//
//  MyStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class MyStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    var stories: [Story] = []
    var totalVotes: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        getAllMyStories()
    }

    func getAllMyStories() {
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
    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
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
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "Header",
                    forIndexPath: indexPath)
                    
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
}
