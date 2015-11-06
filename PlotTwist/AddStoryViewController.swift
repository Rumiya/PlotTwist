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

    @IBOutlet weak var tableView: UITableView!

    var delegate: NewStoryDelegate?

    let mainAuthor = User.currentUser()!
    var firstPage = Page()
    var myStory = Story()
    var invitedUser = User()
    var users: [User] = []
    var selectedIndex: Int = 0
    var newStory: Bool!
    var currentStory: Story!
    var newPage = Page()


    var storyContent: String!
    var storyTitle: String!

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

        if newStory == false {
            if currentStory!.pageCount == 4 {
                self.tableView.hidden = true
                let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
                label.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2 + 100)
                label.textAlignment = NSTextAlignment.Center
                label.text = "You have the last page! End the story the way you see fit, and hit \"Save\" to publish!"
                view.addSubview(label)
            }
        }

    }

    func setupStory() -> Void {

        // TODO: Check if user hasn't been selected as well
        // Initialize first page of story
        firstPage.author = mainAuthor
        firstPage.story = myStory
        firstPage.pageNum = 1

                self.firstPage.textContent = storyContent
                self.firstPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.myStory.pages.append(self.firstPage)

                    // Initialize story
                    self.invitedUser = self.users[self.selectedIndex]
                    self.myStory.storyTitle = self.storyTitle!
                    self.myStory.mainAuthor = self.mainAuthor
                    self.myStory.currentAuthor = self.invitedUser
                    self.myStory.allAuthorIds = [self.mainAuthor.objectId!, self.invitedUser.objectId!]
                    self.myStory.allAuthors.addObject(self.mainAuthor)
                    self.myStory.allAuthors.addObject(self.invitedUser)
                    self.myStory.isLiked = false
                    self.myStory.isPublished = false
                    self.myStory.voteCount = 0
                    self.myStory.pageCount = 1

                    // Add local storage later
                    // myStory.pinInBackground()
                    self.myStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        self.mainAuthor.authoredStories.addObject(self.myStory)
                        self.mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

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
                                    self.delegate?.didAddNewStory(self.myStory, nextAuthor: self.invitedUser)
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                } else {
                                    print("push failed")
                                }
                            })
                        })
                    })
                })
    }

    func addPageToStory() {
        // Initialize Page Object

        newPage.author = mainAuthor
        newPage.story = currentStory
        newPage.pageNum = currentStory.pageCount + 1

                self.newPage.textContent = storyContent
                self.newPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    // Edit Story Properties
                    self.invitedUser = self.users[self.selectedIndex]

                    self.currentStory.incrementKey(Constants.Story.pageCount)
                    print(self.currentStory.pageCount)
                    self.currentStory.pages.append(self.newPage)
                    self.currentStory.currentAuthor = self.invitedUser
                    // Make sure this stuff only gets called once
                    self.currentStory.allAuthorIds.append(self.invitedUser.objectId!)
                    self.currentStory.allAuthors.addObject(self.invitedUser)
                    // work on local data storage later
                    // currentStory.pinInBackground()
                    self.currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        let relation: PFRelation = self.mainAuthor.coAuthoredStories
                        let query = relation.query()
                        query?.whereKey(Constants.Story.objectId, equalTo:self.currentStory.objectId!)

                        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

                            // add story to author's library if not in there already
                            if objects == nil {
                                self.mainAuthor.coAuthoredStories.addObject(self.currentStory)
                                self.mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

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
                                        "alert" : "\(self.mainAuthor.username!) has added you to a story!",
                                        "badge" : "Increment",
                                        "s" : "\(self.currentStory.objectId!)", // Story's object id
                                    ]

                                    let push = PFPush()
                                    push.setQuery(query)
                                    push.setData(data)
                                    push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                        if success {
                                            print("successful push")
                                            if self.currentStory.mainAuthor != self.mainAuthor{
                                                //self.sendPushToMainAuthor()
                                            }
                                            // TODO: delegation
                                             self.delegate?.didAddNewStory(self.currentStory, nextAuthor: self.invitedUser)
                                        } else {
                                            print("push failed")

                                        }
                                        self.navigationController?.popToRootViewControllerAnimated(true)

                                    })
                                }
                            }
                        })
                    })
                })
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
                self.delegate?.didAddNewStory(self.myStory, nextAuthor: self.mainAuthor)
                self.navigationController?.popToRootViewControllerAnimated(true)

            })
        }
    }

    @IBAction func onSaveButtonPressed(sender: UIBarButtonItem) {
        if newStory == true {
            setupStory()
        } else {
            addPageToStory()
        }
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
