//
//  FriendsViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendButtonDelegate, IncomingFriendButtonDelegate, OutgoingFriendButtonDelegate, MyFriendsButtonDelegate, UISearchBarDelegate, UISearchDisplayDelegate, SMSegmentViewDelegate, CNContactPickerDelegate, ContactsButtonDelegate {

    var delegate: FriendListDelegate?
    var searchActive:Bool = false
    var buttonTypeForUser = [User:String]()

    var segmentView: SMSegmentView!


    // Data and Outlets for Table Views

    // 1) Search Table View
    var users: [User] = []
    var filteredUsers: [User] = []
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchView: UIView!

    // 2) Incoming Table View
    var incoming: [User] = []
    @IBOutlet weak var incomingTableView: UITableView!
    @IBOutlet weak var incomingView: UIView!

    // 3) Outgoing Table View
    var outgoing: [User] = []
    @IBOutlet weak var outgoingTableView: UITableView!
    @IBOutlet weak var outgoingView: UIView!

    // 4) Contacts Table View
    var contactMatch: [User] = []
    @IBOutlet weak var contactsView: UIView!
    @IBOutlet weak var contactsTableView: UITableView!

    // 5) My Friends Table View
    var myFriends: [User] = []
    @IBOutlet weak var myFriendsTableView: UITableView!
    @IBOutlet weak var myFriendsView: UIView!

    // MARK - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.allowsSelection = false;
        incomingTableView.allowsSelection = false;
        outgoingTableView.allowsSelection = false;
        myFriendsTableView.allowsSelection = false;
        contactsTableView.allowsSelection = false;
        initSegmentView()
        queryUsers()
    }

    // MARK - UI Initialization Methods
    func initSegmentView() {
        segmentView = SMSegmentView(frame: CGRect(x: 0, y: 67, width: self.view.frame.size.width, height: 40.0), separatorColour: UIColor.blackColor(), separatorWidth: 1.0, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor.whiteColor(), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: 5.0])
        segmentView.delegate = self
        segmentView.addSegmentWithTitle("", onSelectionImage: UIImage(named: "friends_search_light"), offSelectionImage: UIImage(named: "friends_search"))
        segmentView.addSegmentWithTitle("", onSelectionImage: UIImage(named: "friends_incoming_light"), offSelectionImage: UIImage(named: "friends_incoming"))
        segmentView.addSegmentWithTitle("", onSelectionImage: UIImage(named: "friends_outgoing_light"), offSelectionImage: UIImage(named: "friends_outgoing"))
        segmentView.addSegmentWithTitle("", onSelectionImage: UIImage(named: "friends_contacts_light"), offSelectionImage: UIImage(named: "friends_contacts"))
        segmentView.addSegmentWithTitle("", onSelectionImage: UIImage(named: "friends_myfriends_light"), offSelectionImage: UIImage(named: "friends_myfriends"))
        segmentView.selectSegmentAtIndex(0)
        self.view.addSubview(segmentView)

    }

    // MARK - Segment View Delegate Methods
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        switch (index) {
        case 0:
            searchView.hidden = false
            incomingView.hidden = true
            outgoingView.hidden = true
            contactsView.hidden = true
            myFriendsView.hidden = true
        case 1:
            searchView.hidden = true
            incomingView.hidden = false
            outgoingView.hidden = true
            contactsView.hidden = true
            myFriendsView.hidden = true
        case 2:
            searchView.hidden = true
            incomingView.hidden = true
            outgoingView.hidden = false
            contactsView.hidden = true
            myFriendsView.hidden = true
        case 3:
            searchView.hidden = true
            incomingView.hidden = true
            outgoingView.hidden = true
            contactsView.hidden = false
            myFriendsView.hidden = true



        case 4:
            searchView.hidden = true
            incomingView.hidden = true
            outgoingView.hidden = true
            myFriendsView.hidden = false
            contactsView.hidden = true

        default:
            break
        }
    }

    // MARK - Parse Query Methods
    func queryUsers() {

        buttonTypeForUser.removeAll()
        users.removeAll()
        incoming.removeAll()
        outgoing.removeAll()
        myFriends.removeAll()
        contactMatch.removeAll()

        // Fetch contacts from address book
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        let containerId = CNContactStore().defaultContainerIdentifier()
        let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
        let contacts: [CNContact]?
        do {
            contacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
        } catch _ {
            contacts = nil
        }

        var contactEmails = [String]()
        for contact in contacts! {
            for emailAddress in contact.emailAddresses{
                contactEmails.append(emailAddress.value as! String)
                //print(contactEmails.last)
            }
        }


        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: (User.currentUser()?.objectId)!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let tempUsers = objects as! [User]
                //self.users = objects as! [User]

                var count = 0
                for user in tempUsers {

                    // Then compare with parse database to see if there are any matching emails

                    if contactEmails.contains(user.email!){
                        self.contactMatch.append(user)
                        //print(self.contactMatch.last)
                    }

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
                                self.myFriends.append(user)
                            case Constants.Activity.Requests.outgoing:
                                if activity.toUser == User.currentUser()!{
                                    self.buttonTypeForUser[user] = Constants.User.ButtonType.incoming
                                    self.incoming.append(user)
                                } else {
                                    self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                                    self.outgoing.append(user)
                                }
                            default:
                                self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                                self.users.append(user)
                            }

                        } else {
                            self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                            self.users.append(user)
                        }
                        count++


                        if (count == tempUsers.count) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.searchTableView.reloadData()
                                self.incomingTableView.reloadData()
                                self.outgoingTableView.reloadData()
                                self.contactsTableView.reloadData()
                                self.myFriendsTableView.reloadData()
                            })
                        }
                    }
                }
            } else {
                print("error retrieving")
            }
        })
    }

    // MARK - Table View Helper Methods
    func currentArray() -> Array<User> {
        if (searchActive) {
            return self.filteredUsers
        } else {
            return self.users
        }
    }

    // MARK: Friend Button Delegate Methods
    func didPressFriendButton(button: UIButton) {
        switch (segmentView.indexOfSelectedSegment) {
        case 0:
            let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: searchTableView)
            let indexPath: NSIndexPath = searchTableView.indexPathForRowAtPoint(touchPoint)!
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
                        self.searchTableView.reloadData()
                    })
                }
            } else if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.pending)) {
                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.sendRequest), forState: .Normal)
                })
                PTUtiltiy.undoFriendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                        self.searchTableView.reloadData()
                    })
                }
            }

        case 1:
            let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: incomingTableView)
            let indexPath: NSIndexPath = incomingTableView.indexPathForRowAtPoint(touchPoint)!
            let user = incoming[indexPath.row]


            let alertController = UIAlertController(title: "Accept Request", message: "Are you sure?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Accept", style: .Default) { (alert: UIAlertAction!) -> Void in
                button.enabled = false

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named:Constants.User.ButtonType.acceptedText), forState: .Normal)
                })


                PTUtiltiy.acceptFriendInBackground(user) {(result: Bool) -> Void in
                    self.buttonTypeForUser[user] = Constants.User.ButtonType.accepted

                }
            }

            let rejectAction = UIAlertAction(title: "Reject", style: .Destructive) { (alert: UIAlertAction!) -> Void in
                button.enabled = false

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named:Constants.User.ButtonType.rejectedText), forState: .Normal)
                })

                PTUtiltiy.rejectFriendInBackground(user) {(result: Bool) -> Void in
                    self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(rejectAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)


        case 2:
            let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: outgoingTableView)
            let indexPath: NSIndexPath = outgoingTableView.indexPathForRowAtPoint(touchPoint)!
            let user = outgoing[indexPath.row]



            if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.pending)) {

                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.sendRequest), forState: .Normal)
                })
                PTUtiltiy.undoFriendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                        self.searchTableView.reloadData()
                    })
                }
            } else {
                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.pending), forState: .Normal)
                })
                PTUtiltiy.friendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                        self.searchTableView.reloadData()
                    })
                }
            }


        case 3:
            let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: searchTableView)
            let indexPath: NSIndexPath = searchTableView.indexPathForRowAtPoint(touchPoint)!
            let user = contactMatch[indexPath.row]

            if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.sendRequest)) {
                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.pending), forState: .Normal)
                })
                PTUtiltiy.friendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                        self.searchTableView.reloadData()
                    })
                }
            } else if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.pending)) {
                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.sendRequest), forState: .Normal)
                })
                PTUtiltiy.undoFriendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                        self.searchTableView.reloadData()
                    })
                }
            }
        case 4:
            let touchPoint: CGPoint = button.convertPoint(CGPointZero, toView: myFriendsTableView)
            let indexPath: NSIndexPath = myFriendsTableView.indexPathForRowAtPoint(touchPoint)!
            let user = myFriends[indexPath.row]

            if (button.backgroundImageForState(.Normal) == UIImage(named:Constants.User.ButtonType.accepted)) {

                let alertController = UIAlertController(title: "Remove Friend", message: "Are you sure?", preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Yes", style: .Destructive) { (alert: UIAlertAction!) -> Void in

                    button.enabled = false
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.sendRequest), forState: .Normal)
                    })
                    PTUtiltiy.unFriendUserInBackground(user) {(result: Bool) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in

                            button.enabled = true
                            self.buttonTypeForUser[user] = Constants.User.ButtonType.sendRequest
                            self.searchTableView.reloadData()
                        })
                    }


                    PTUtiltiy.acceptFriendInBackground(user) {(result: Bool) -> Void in
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.accepted

                    }
                }


                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(yesAction)
                alertController.addAction(cancelAction)
                presentViewController(alertController, animated: true, completion: nil)
            } else {
                button.enabled = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    button.setBackgroundImage(UIImage(named: Constants.User.ButtonType.pending), forState: .Normal)
                })
                PTUtiltiy.friendUserInBackground(user) {(result: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        button.enabled = true
                        self.buttonTypeForUser[user] = Constants.User.ButtonType.pending
                        self.searchTableView.reloadData()
                    })
                }
            }

        default:
            break
        }

    }


    // MARK - IBActions
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
        self.searchTableView.reloadData()
    }

    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == searchTableView {

            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTableViewCell

            cell.delegate = self

            cell.usernameLabel?.text = currentArray()[indexPath.row].username
            if buttonTypeForUser.count > 0 {
                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[currentArray()[indexPath.row]]!), forState: .Normal)
            }
            return cell

        } else if tableView == incomingTableView {

            let cell = tableView.dequeueReusableCellWithIdentifier("IncomingFriendCell") as! IncomingFriendTableViewCell

            cell.delegate = self

            cell.usernameLabel?.text = incoming[indexPath.row].username
            if buttonTypeForUser.count > 0 {
                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[incoming[indexPath.row]]!), forState: .Normal)
            }
            return cell

        } else if tableView == outgoingTableView {

            let cell = tableView.dequeueReusableCellWithIdentifier("OutgoingFriendCell") as! OutgoingFriendTableViewCell

            cell.delegate = self

            cell.usernameLabel?.text = outgoing[indexPath.row].username
            if buttonTypeForUser.count > 0 {
                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[outgoing[indexPath.row]]!), forState: .Normal)
            }
            return cell

        } else if tableView == contactsTableView {

            let cell = tableView.dequeueReusableCellWithIdentifier("ContactsCell") as! ContactsTableViewCell

            cell.delegate = self

            cell.usernameLabel?.text = contactMatch[indexPath.row].username
            if buttonTypeForUser.count > 0 {
                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[contactMatch[indexPath.row]]!), forState: .Normal)
            }
            return cell
            
        }else if tableView == myFriendsTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyFriendsCell") as! MyFriendsTableViewCell
            
            cell.delegate = self
            
            cell.usernameLabel?.text = myFriends[indexPath.row].username
            if buttonTypeForUser.count > 0 {
                cell.friendButton.setBackgroundImage(UIImage(named: buttonTypeForUser[myFriends[indexPath.row]]!), forState: .Normal)
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendTableViewCell
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            
            return currentArray().count
            
        } else if tableView == incomingTableView {
            
            return incoming.count
            
        } else if tableView == outgoingTableView {
            
            return outgoing.count
            
        } else if tableView == myFriendsTableView {
            
            return myFriends.count
            
        }else if tableView == contactsTableView {

            return contactMatch.count

        } else {
            return 0
        }
    }
    
}

