//
//  OutboxViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/9/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class OutboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeInvitedAuthorsDelegate {

    @IBOutlet weak var tableView: UITableView!

    var outgoingStories: [Story] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        queryOutgoingStories()
    }

    func queryOutgoingStories() {

        let userQuery = User.query()
        userQuery?.whereKey(Constants.User.objectId, equalTo: (User.currentUser()?.objectId)!)

        let outgoingStoryQuery = Story.query()
        outgoingStoryQuery?.whereKey(Constants.Story.allAuthors, matchesQuery: userQuery!)
        outgoingStoryQuery?.whereKey(Constants.Story.isPublished, equalTo: false)
        outgoingStoryQuery?.includeKey(Constants.Story.allAuthorIds)
        outgoingStoryQuery?.includeKey(Constants.Story.currentAuthor)
        outgoingStoryQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            let allStories = objects as! [Story]
            var count = 0
            for story in allStories {
                let index = story.allAuthorIds.count
                if story.allAuthorIds[index-2] == User.currentUser()?.objectId {
                    self.outgoingStories.append(story)
                }
                count = count + 1

                if count == allStories.count {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.outgoingStories.sortInPlace({ $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedAscending })
                        self.tableView.reloadData()
                    })
                }
            }

        })
    }

    func didCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func didSendToNewAuthor() {
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OutboxCell") as! OutboxTableViewCell
        cell.storyTitleLabel.text = self.outgoingStories[indexPath.row].storyTitle
        cell.dateCreatedLabel.text = PTUtiltiy.getElapsedTimeFromDate(self.outgoingStories[indexPath.row].createdAt!)
        cell.invitedAuthorLabel.text = self.outgoingStories[indexPath.row].currentAuthor.username

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outgoingStories.count
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChangeAuthorSegue" {
            let vc = segue.destinationViewController as! ChangeInvitedAuthorViewController
            vc.delegate = self
            vc.story = self.outgoingStories[tableView.indexPathForSelectedRow!.row]
            vc.selectedIndex = tableView.indexPathForSelectedRow?.row
        }
    }
    
    
}
