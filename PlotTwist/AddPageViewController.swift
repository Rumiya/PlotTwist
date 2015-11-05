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

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let author = User.currentUser()!
    var currentStory: Story!
    var newPage = Page()
    var invitedUser = User()
    var users: [User] = []
    var selectedIndex: Int = 0

    var delegate: NewPageDelegate?


    init(story: Story?) {
        currentStory = story
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(animated: Bool) {

        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        if currentStory.pageCount == 4 {
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
        self.delegate?.didCancelNewPage()
    }

    @IBAction func onSaveButtonPressed(sender: UIBarButtonItem) {

        if (textField.text == nil) { // Need to check if invited user has been selected as well
            presentEmptyFieldAlertController()
        } else {
            // Initialize Page Object
            newPage.author = author
            newPage.story = currentStory
            newPage.pageNum = currentStory.pageCount + 1
            if let data = self.textField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
                let file = PFFile(name:"content.txt", data:data)
                file!.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.newPage.content = file!
                    self.newPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        // Edit Story Properties
                        self.invitedUser = self.users[self.selectedIndex]

                        self.currentStory.incrementKey(Constants.Story.pageCount)
                        print(self.currentStory.pageCount)
                        self.currentStory.pages.append(self.newPage)
                        self.currentStory.currentAuthor = self.invitedUser
                        // Make sure this stuff only gets called once
                        self.currentStory.allAuthorIds.append(self.author.objectId!)
                        self.currentStory.allAuthors.addObject(self.author)
                        // work on local data storage later
                        // currentStory.pinInBackground()
                        self.currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            let relation: PFRelation = self.author.coAuthoredStories
                            let query = relation.query()
                            query?.whereKey(Constants.Story.objectId, equalTo:self.currentStory.objectId!)

                            query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

                                // add story to author's library if not in there already
                                if objects == nil {
                                    self.author.coAuthoredStories.addObject(self.currentStory)
                                    self.author.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                                    })
                                } else {
                                    if (self.newPage.pageNum == 5) {
                                        print("publish story")
                                        self.publishStory(self.currentStory)
                                    } else {

                                        // Assign value to invited User based on user interaction with view
                                        let innerQuery = User.query()
                                        innerQuery!.whereKey(Constants.User.objectId, equalTo: self.invitedUser.objectId!)

                                        let query = PFInstallation.query()
                                        query?.whereKey("user", matchesQuery:innerQuery!)

                                        let data = [
                                            "alert" : "\(self.author.username!) wants you to add to a story!",
                                            "badge" : "Increment",
                                            "s" : "\(self.currentStory.objectId!)", // Story's object id
                                        ]

                                        let push = PFPush()
                                        push.setQuery(query)
                                        push.setData(data)
                                        push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                            if success {
                                                print("successful push")
                                                if self.currentStory.mainAuthor != self.author{
                                                    //self.sendPushToMainAuthor()
                                                }
                                                self.delegate?.didAddNewPage(self.currentStory, nextAuthor: self.invitedUser)
                                            } else {
                                                print("push failed")
                                            }
                                        })
                                    }
                                }
                            })
                        })
                    })
                })
            } else {
                // TODO: handle error in data encoding here
            }
        }
    }

    func sendPushToMainAuthor() {
        let innerQuery = User.query()
        innerQuery!.whereKey(Constants.User.objectId, equalTo:self.currentStory.mainAuthor.objectId!)

        let query = PFInstallation.query()
        query?.whereKey("user", matchesQuery:innerQuery!)
        let data = [
            "alert" : "Your story has been updated!",
            "s" : "\(self.currentStory.objectId)" // Story's object id
        ]

        let push = PFPush()
        push.setQuery(query)
        push.setData(data)
        push.sendPushInBackground()
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
                "s" : "\(self.currentStory.objectId!)", // Story's object id
            ]

            let push = PFPush()
            push.setQuery(query)
            push.setData(data)
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                self.delegate?.didEndStory(self.currentStory)
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
        textField.resignFirstResponder()
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