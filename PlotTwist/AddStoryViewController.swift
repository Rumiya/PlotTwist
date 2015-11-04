//
//  AddStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse



class AddStoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var starterPickerView: UIPickerView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var delegate: NewStoryDelegate?

    let mainAuthor = User.currentUser()!
    var firstPage = Page()
    var myStory = Story()
    var invitedUser = User()
    var users: [User] = []
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
            } else {
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
            // Initialize first page of story
            firstPage.author = mainAuthor
            firstPage.story = myStory
            firstPage.pageNum = 1
            if let data = self.contentTextField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
                let file = PFFile(name:"content.txt", data:data)
                file!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.firstPage.content = file!
                    self.firstPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        self.myStory.pages.append(self.firstPage)

                        // Initialize story
                        self.myStory.storyTitle = self.storyNameTextField.text!
                        self.myStory.mainAuthor = self.mainAuthor
                        self.myStory.allAuthorIds = [self.mainAuthor.objectId!]
                        self.myStory.currentAuthor = self.mainAuthor
                        self.myStory.isLiked = false
                        self.myStory.isPublished = false
                        self.myStory.voteCount = 0
                        self.myStory.pageCount = 1

                        // TODO: find a spot for this relation later
                        /*
                        self.myStory.allAuthors.addObject(self.mainAuthor)
                        */

                        // Add local storage later
                        // myStory.pinInBackground()
                        self.myStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            self.mainAuthor.authoredStories.addObject(self.myStory)
                            self.mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                                self.invitedUser = self.users[self.selectedIndex]
                                let innerQuery = User.query()
                                innerQuery!.whereKey(Constants.User.objectId, equalTo:self.invitedUser.objectId!)

                                let query = PFInstallation.query()
                                query?.whereKey("user", matchesQuery:innerQuery!)

                                let data = [
                                    "alert" : "\(self.mainAuthor.username!) has started a story named \"\(self.myStory.storyTitle)\" and invited to you contribute next!",
                                    "badge" : "Increment",
                                    "s" : "\(self.myStory.objectId)", // Story's object id
                                ]

                                let push = PFPush()
                                push.setQuery(query)
                                push.setData(data)
                                push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                    if success {
                                        print("successful push")
                                        self.delegate?.didAddNewStory()
                                        self.navigationController?.popViewControllerAnimated(true)
                                    } else {
                                        print("push failed")
                                    }
                                })
                            })
                        })
                    })
                })
            } else {
                // TODO: handle error in data encoding here
            }

        }
    }

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Complete all the fields before starting your story!", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        storyNameTextField.resignFirstResponder()
        contentTextField.resignFirstResponder()
    }

    @IBAction func onSaveButtonPressed(sender: UIBarButtonItem) {
        setupStory()
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
