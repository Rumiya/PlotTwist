//
//  ActivityViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var stories: [Story] = []
    var turnToWriteCount: Int = 0
    let currentUser = User.currentUser()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func checkForActiveStories() {

        // First check local data store
        let queryLocalData = Story.query()
        queryLocalData?.fromLocalDatastore()
        queryLocalData?.whereKey(Constants.Story.isPublished, equalTo: false)

        queryLocalData?.findObjectsInBackground().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                return task
            }


            let allStories = task.result as! [Story]

            for story in allStories {
                if story.currentAuthor.isEqual(self.currentUser){
                    self.turnToWriteCount = self.turnToWriteCount + 1
                }
                if story.allAuthorIds.contains(self.currentUser.objectId!){
                    self.stories.append(story)
                }
            }
            // TODO: outlet table view
            // tableView.reloadData()
            self.navigationController!.tabBarItem.badgeValue = "\(self.turnToWriteCount)"

            // Not Check For Any New Data From Parse
            let query = Story.query()
            queryLocalData?.whereKey(Constants.Story.isPublished, equalTo: false)

            // Query for new results from the network
            query?.findObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in

                return Story.unpinAllObjectsInBackgroundWithName("MyActiveStories").continueWithSuccessBlock({ (ignored: BFTask!) -> AnyObject! in

                    // Cache new results
                    let allUpdatedStories = task.result as! [Story]
                    var newTurnToWriteCount: Int = 0;
                    var updatedActiveStories: [Story] = []
                    for story in allUpdatedStories{
                        if story.currentAuthor.isEqual(self.currentUser){
                            newTurnToWriteCount = newTurnToWriteCount + 1
                        }
                        if story.allAuthorIds.contains(self.currentUser.objectId!){
                            updatedActiveStories.append(story)
                        }
                    }

                    if updatedActiveStories != self.stories
                    {
                        self.stories = updatedActiveStories
                        self.turnToWriteCount = newTurnToWriteCount
                        // TODO: outlet table view
                        // tableView.reloadData()
                    }
                    return Story.pinAllInBackground(updatedActiveStories, withName: "MyActiveStories")
            })
        })
        return task
    })
}


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

    // Here check if author is current author, if so indicate on cells

        return cell
}

}
