//
//  FriendsViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendButtonDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!

    var delegate: FriendListDelegate?

    var users: [User] = []
    var filteredUsers: [User] = []
    var activityItems: [Activity] = []
    var searchActive:Bool = false
    var buttonTypeForUser = [User:String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        queryUsers()

    }

    func queryUsers() {

        buttonTypeForUser.removeAll()
        users.removeAll()
        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: (User.currentUser()?.objectId)!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let tempUsers = objects as! [User]
                //self.users = objects as! [User]

                for user in tempUsers {

                    let friendOutgoingQuery = Activity.query()
                    friendOutgoingQuery?.whereKey(Constants.Activity.fromUser, equalTo: User.currentUser()!)
                    friendOutgoingQuery?.whereKey(Constants.Activity.toUser, equalTo: user)

                    let friendIncomingQuery = Activity.query()
                    friendIncomingQuery?.whereKey(Constants.Activity.fromUser, equalTo: user)
                    friendIncomingQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)

                    let allFriendQuery = PFQuery.orQueryWithSubqueries([friendOutgoingQuery!, friendIncomingQuery!])
                    allFriendQuery.whereKey(Constants.Activity.type, equalTo: Constants.Activity.Type.friend)
                    allFriendQuery.includeKey(Constants.Activity.fromUser)
                    allFriendQuery.includeKey(Constants.Activity.toUser)
                    allFriendQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in

                        if objects?.count != 0 {
                            let activity = objects?.first as! Activity

                            switch activity.requestType {
                            case Constants.Activity.Requests.confirmed:
                                self.buttonTypeForUser[user] = Constants.User.ButtonType.accepted
                            case Constants.Activity.Requests.outgoing:
                                if activity.toUser == User.currentUser()!{
                                    self.buttonTypeForUser[user] = Constants.User.ButtonType.incoming
                                } else {
                                    self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                                }
                            default:
                                self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                            }

                        } else {
                            self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                        }

                        self.users.append(user)

                        if (self.users.count == tempUsers.count) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            } else {
                print("error retrieving")
            }
        })
    }

    func currentArray() -> Array<User> {
        if (searchActive) {
            return self.filteredUsers
        } else {
            return self.users
        }
    }

    // MARK: Friend Button Delegate Methods
    func didPressFriendButton(button: UIButton) {
        let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: tableView)
        let indexPath: NSIndexPath = tableView.indexPathForRowAtPoint(touchPoint)!

        let user = currentArray()[indexPath.row]

        if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.sendRequest)) {
            button.enabled = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.pending), forState: .Normal)
            })
            PTUtiltiy.friendUserInBackground(user) {(result: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    button.enabled = true
                    self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                    self.tableView.reloadData()
                })
            }
        } else if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.accepted)) {
            let alertController = UIAlertController(title: "Remove Friend", message: "Are you sure?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: .Destructive) { (alert: UIAlertAction!) -> Void in
                button.enabled = false

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named:Constants.User.ButtonType.sendRequest), forState: .Normal)
                })
                PTUtiltiy.unFriendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                        self.tableView.reloadData()
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.incoming)) {
            button.enabled = false
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.accepted), forState: .Normal)
            })
            PTUtiltiy.acceptFriendInBackground(user, completion: { (result) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    button.enabled = true
                    self.buttonTypeForUser[user] = Constants.User.ButtonType.accepted
                    self.tableView.reloadData()
                })
            })
        }
    }

    @IBAction func onDoneButtonPressed(sender: UIButton) {
        self.delegate?.didAcceptFriend()
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: Search Bar Helper and Delegate Methods

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        filteredUsers = users.filter({ (user: User) -> Bool in
            let stringMatch = user.username!.uppercaseString.rangeOfString(searchText.uppercaseString)
            return (stringMatch != nil)
        })
        if(filteredUsers.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }


    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTableViewCell

        cell.delegate = self

        cell.usernameLabel?.text = currentArray()[indexPath.row].username
        if buttonTypeForUser.count > 0 {
            cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[currentArray()[indexPath.row]]!), forState: .Normal)
        }

//        if (searchActive) {
//            cell.usernameLabel?.text = filteredUsers[indexPath.row].username
//            if buttonTypeForUser.count > 0 {
//                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[filteredUsers[indexPath.row]]!), forState: .Normal)
//            }
//
//        } else {
//            cell.usernameLabel?.text = users[indexPath.row].username
//            if buttonTypeForUser.count > 0 {
//
//                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[users[indexPath.row]]!), forState: .Normal)
//            }
//        }

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentArray().count
    }
    
}

