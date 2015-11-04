//
//  AddStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class AddStoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var starterPickerView: UIPickerView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!


    // Need UI Element to select friend to pass the story on to


    let mainAuthor = User.currentUser()!
    var firstPage = Page()
    var myStory = Story()
    var invitedUser = User()
    var users: [User] = []
    var checked = [Bool]()
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: mainAuthor.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
            self.users = objects as! [User]
               print(" no error  ")
                self.tableView.reloadData()
                
            }else {
                
                print("error retrieving")
            }
        })
    }

    func setupStory() -> Void {

        // First make sure all fields are entered
        // TODO: Check if user hasn't been selected as well
        if (storyNameTextField.text == nil || contentTextField.text == nil){
            presentEmptyFieldAlertController()
        } else {

            mainAuthor.authoredStories.addObject(myStory)
            mainAuthor.saveInBackground()

            // Initialize first page of story
            firstPage.author = mainAuthor
            firstPage.story = myStory
            firstPage.pageNum = 1
            if let data = self.contentTextField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
                let file = PFFile(name:"content.txt", data:data)
                file!.saveInBackground()
                firstPage.content = file!
            } else {
                // TODO: handle error in data encoding here
            }
            firstPage.saveInBackground()

            // Initialize story
            myStory.mainAuthor = mainAuthor
            myStory.allAuthors.addObject(mainAuthor)
            myStory.allAuthorIds = [mainAuthor.objectId!]
            myStory.currentAuthor = mainAuthor
            myStory.pages.append(firstPage)
            myStory.isLiked = false
            myStory.isPublished = false
            myStory.voteCount = 0
            myStory.pageCount = 1

            // Add local storage later
            // myStory.pinInBackground()
            myStory.saveInBackground()

            // Assign value to invited User based on user interaction with view
             invitedUser = users[selectedIndex]
            // TODO: Add Push Notifications to Parse and add certificate
            // Maybe need to keep track of the Story's objectId behind the scenes so co-authors can access it easliy
            // Also not sure if we should send notifications to all invited, or just the first on the list
            let innerQuery = User.query()
            innerQuery!.whereKey(Constants.User.objectId, equalTo: invitedUser.objectId!)

            let query = PFInstallation.query()
            query?.whereKey("user", matchesQuery:innerQuery!)

            let data = [
                "alert" : "\(mainAuthor.username) has started a story and invited to you contribute next!",
                "badge" : "Increment",
                "s" : "\(myStory.objectId)", // Story's object id
            ]

            let push = PFPush()
            push.setQuery(query)
            push.setData(data)
            push.sendPushInBackground()

//            PFPush.sendPushMessageToQueryInBackground(query!, withMessage: "\(mainAuthor.username) has started a story and invited to you contribute next!")
        }
    }

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Complete all the fields before starting your story!", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func onSaveButtonPressed(sender: UIBarButtonItem) {
        setupStory()
    }

    @IBAction func onCancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.users.count
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.users[indexPath.row].username
       
        if self.selectedIndex == indexPath.row  {
            
            cell.accessoryType = .Checkmark
        }
        else {
            
            cell.accessoryType = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    

}
