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
            if (error == nil) {
            let activities = objects as! [Activity]

            var friendIndex = 0
            for activity in activities {
                if (activity.toUser.objectId != User.currentUser()?.objectId) {
                    self.friends.append(activity.toUser)
                    if(activity.toUser.username == self.story?.currentAuthor.username){
                        self.selectedIndex = friendIndex
                    }
                    friendIndex++
                }

                if (activity.fromUser.objectId != User.currentUser()?.objectId) {
                    self.friends.append(activity.fromUser)
                    if(activity.fromUser.username == self.story?.currentAuthor.username){
                        self.selectedIndex = friendIndex
                    }
                    friendIndex++
                }



                if (self.friends.count == activities.count) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        self.tableView.reloadData()
                    })
                }

            }
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

        PTActivityIndicator.show()

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

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                PTActivityIndicator.dismiss()
            })

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

    // MARK: Error Controller
    func presentErrorWithMessage(message: String) {
        let alertController = UIAlertController(title: "Error retrieving data", message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}
