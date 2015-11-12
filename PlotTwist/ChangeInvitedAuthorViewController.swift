//
//  ChangeInvitedAuthorViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/9/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ChangeInvitedAuthorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: ChangeInvitedAuthorsDelegate?

    var story: Story?

    var friends: [User] = []

    var selectedIndex: Int?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        friends.removeAll()
        let activityOneQuery = Activity.query()
        activityOneQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)

        let activityTwoQuery = Activity.query()
        activityTwoQuery?.whereKey(Constants.Activity.fromUser, equalTo: User.currentUser()!)


        let activityQuery = PFQuery.orQueryWithSubqueries([activityOneQuery!, activityTwoQuery!])
        activityQuery.whereKey(Constants.Activity.requestType, equalTo: Constants.Activity.Requests.confirmed)
        activityQuery.includeKey(Constants.Activity.toUser)
        activityQuery.includeKey(Constants.Activity.fromUser)
        activityQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            let activities = objects as! [Activity]

            for activity in activities {
                if (activity.toUser.objectId != User.currentUser()?.objectId) {
                    self.friends.append(activity.toUser)
                }

                if (activity.fromUser.objectId != User.currentUser()?.objectId) {
                    self.friends.append(activity.fromUser)
                }

                if (self.friends.count == activities.count) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        self.tableView.reloadData()
                    })
                }

            }

        })
    }


    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!

        cell.textLabel?.text = self.friends[indexPath.row].username
        if self.selectedIndex == indexPath.row  {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    // MARK: IBActions
    @IBAction func onSaveAndSendButtonPressed(sender: UIButton) {

        let invitedUser = self.friends[selectedIndex!]
        story?.currentAuthor = invitedUser
        story?.allAuthorIds.removeLast()
        story?.allAuthors.removeObject(invitedUser)
        story?.allAuthorIds.append(invitedUser.objectId!)
        story?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

            // Assign value to invited User based on user interaction with view
            let innerQuery = User.query()
            innerQuery!.whereKey(Constants.User.objectId, equalTo: invitedUser.objectId!)

            let query = PFInstallation.query()
            query?.whereKey("user", matchesQuery:innerQuery!)

            let data = [
                "alert" : "\(User.currentUser()!.username!) has added you to a story!",
                "badge" : "Increment",
                "s" : "\(self.story!.objectId!)", // Story's object id
            ]

            let push = PFPush()
            push.setQuery(query)
            push.setData(data)
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("successful push")
                    self.delegate?.didSendToNewAuthor()
                } else {
                    print("push failed")
                }
            })
        })
    }
    
    @IBAction func onCancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}
