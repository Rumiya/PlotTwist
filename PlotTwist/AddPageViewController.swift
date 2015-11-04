//
//  AddPageViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class AddPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentTextField: UITextView!

    @IBOutlet weak var tableView: UITableView!

    let author = User.currentUser()!
    var currentStory: Story!
    var newPage = Page()
    var invitedUser = User()
    var users: [User] = []
    var selectedIndex: Int = 0

    init(story: Story?) {
        currentStory = story
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make sure this stuff only gets called once
        currentStory.currentAuthor = author
        currentStory.allAuthorIds.append(author.objectId!)
        currentStory.allAuthors.addObject(author)

        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: author.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.users = objects as! [User]
                print(" no error  ")
                self.tableView.reloadData()
            } else {
                print("error retrieving")
            }
        })

        if currentStory.pageCount == 9 {
            self.tableView.hidden = true
            let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
            label.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2 + 100)
            label.textAlignment = NSTextAlignment.Center
            label.text = "You have the last page! End the story the way you see fit, and hit \"Save\" to publish!"
            view.addSubview(label)
        }

        // TODO: check current page number and adjust UI as a result

    }

    @IBAction func onCancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSaveButtonPressed(sender: UIBarButtonItem) {

        if (contentTextField.text == nil) { // Need to check if invited user has been selected as well
            presentEmptyFieldAlertController()
        } else {


            // Initialize Page Object
            newPage.author = author
            newPage.story = currentStory
            newPage.pageNum = currentStory.pageCount + 1
            if let data = self.contentTextField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
                let file = PFFile(name:"content.txt", data:data)
                file!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.newPage.content = file!
                    self.newPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        // Edit Story Properties
                        self.currentStory.incrementKey(Constants.Story.pageCount)
                        self.currentStory.pages.append(self.newPage)
                        // work on local data storage later
                        // currentStory.pinInBackground()
                        self.currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            let relation: PFRelation = self.author.coAuthoredStories
                            let query = relation.query()
                            query?.whereKey(Constants.Story.objectId, equalTo:self.currentStory.objectId!)
                            query?.countObjectsInBackgroundWithBlock({ (count: integer_t, error: NSError?) -> Void in
                                // add story to author's library if not in there already
                                if count == 0 {
                                    self.author.coAuthoredStories.addObject(self.currentStory)
                                    self.author.saveInBackground()
                                }
                            })
                        })

                        if (self.newPage.pageNum == 10) {
                            self.publishStory(self.currentStory)

                        } else {

                            // Assign value to invited User based on user interaction with view
                            self.invitedUser = self.users[self.selectedIndex]
                            let innerQuery = User.query()
                            innerQuery!.whereKey(Constants.User.objectId, equalTo: self.invitedUser.objectId!)

                            let query = PFInstallation.query()
                            query?.whereKey("user", matchesQuery:innerQuery!)

                            let data = [
                                "alert" : "\(self.author.username!) has started a story and invited to you contribute next!",
                                "badge" : "Increment",
                                "s" : "\(self.currentStory.objectId!)", // Story's object id
                            ]

                            let push = PFPush()
                            push.setQuery(query)
                            push.setData(data)
                            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                if success {
                                    print("successful push")
                                    self.navigationController?.popViewControllerAnimated(true)
                                } else {
                                    print("push failed")
                                }
                            })
                        }
                    })

                })
            } else {
                // TODO: handle error in data encoding here
            }
        }
    }

    func publishStory(story: Story) -> Void {
        story.isPublished = true

        story.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            // TODO: delegation here to add story to main feed?

            let innerQuery = User.query()
            innerQuery?.whereKey(Constants.User.objectId, containedIn: self.currentStory.allAuthorIds)

            let query = PFInstallation.query()
            query?.whereKey("user", matchesQuery:innerQuery!)

            let data = [
                "alert" : "A story you contibuted to has been published!",
                "badge" : "Increment",
                "s" : "\(self.currentStory.objectId!)", // Story's object id
            ]

            let push = PFPush()
            push.setQuery(query)
            push.setData(data)
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Don't forget to add to the story!", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        contentTextField.resignFirstResponder()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
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


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }


}