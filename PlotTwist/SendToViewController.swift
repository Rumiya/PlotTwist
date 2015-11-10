//
//  SendToViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/6/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class SendToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: DecrementNotificationsCountDelegate?
    var story: Story?
    var users: [User] = []
    var storyTitle: String?
    var storyContent: String!

    var selectedIndex: Int?

    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var sendButton: UIButton!

    var isNewStory: Bool?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        users.removeAll()
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
                    self.users.append(activity.toUser)
                }

                if (activity.fromUser.objectId != User.currentUser()?.objectId) {
                    self.users.append(activity.fromUser)
                }

                if (self.users.count == activities.count) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        self.tableView.reloadData()
                    })
                }

            }
            
        })

        if isNewStory == false {
            if story!.pageCount == 4 {
                self.tableView.hidden = true
                self.headerLabel.text = "Last Page!"
            }
        }


    }

    override func viewWillAppear(animated: Bool) {

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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }

    @IBAction func onSaveAndSendButtonPressed(sender: UIButton) {

        if (isNewStory == true){
            createNewStory()
        } else {
            createNewPage()
        }
    }

    func createNewStory(){
        // TODO: Check if user hasn't been selected as well
        // Initialize first page of story

        var firstPage: Page!
        let mainAuthor = User.currentUser()!
        var invitedUser: User!
        let newStory = Story()
        firstPage = Page()
        firstPage.author = mainAuthor
        firstPage.story = newStory
        firstPage.pageNum = 1

        firstPage.textContent = storyContent
        firstPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            newStory.pages.append(firstPage)

            // Initialize story
            invitedUser = self.users[self.selectedIndex!]
            newStory.storyTitle = self.storyTitle!
            newStory.mainAuthor = mainAuthor
            newStory.currentAuthor = invitedUser
            newStory.allAuthorIds = [mainAuthor.objectId!, invitedUser.objectId!]
            newStory.allAuthors.addObject(mainAuthor)
            newStory.allAuthors.addObject(invitedUser)
            newStory.isLiked = false
            newStory.isPublished = false
            newStory.voteCount = 0
            newStory.pageCount = 1

            // Add local storage later
            // story.pinInBackground()
            newStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                mainAuthor.authoredStories.addObject(newStory)
                mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                    let innerQuery = User.query()
                    innerQuery!.whereKey(Constants.User.objectId, equalTo:invitedUser.objectId!)

                    let query = PFInstallation.query()
                    query?.whereKey("user", matchesQuery:innerQuery!)
                    let data = [
                        "alert" : "\(mainAuthor.username!) has started a story named \"\(newStory.storyTitle)\" and invited to you contribute next!",
                        "badge" : "Increment",
                        "s" : "\(newStory.objectId)", // Story's object id
                    ]

                    let push = PFPush()
                    push.setQuery(query)
                    push.setData(data)
                    push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success {
                            print("successful push")
                            self.goBackHome()
                        } else {
                            print("push failed")
                        }
                    })
                })
            })
        })
    }

    func createNewPage(){
        // Initialize Page Object
        let newPage = Page()
        let mainAuthor = User.currentUser()!
        var invitedUser: User!
        let currentStory = story!

        newPage.author = mainAuthor
        newPage.story = currentStory
        newPage.pageNum = currentStory.pageCount + 1

        newPage.textContent = storyContent
        newPage.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            // Edit Story Properties
            if (newPage.pageNum == 5){
                currentStory.incrementKey(Constants.Story.pageCount)
                currentStory.pages.append(newPage)
                currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    let relation: PFRelation = mainAuthor.coAuthoredStories
                    let query = relation.query()
                    query?.whereKey(Constants.Story.objectId, equalTo:currentStory.objectId!)

                    query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                        if objects?.count == 0 {
                            mainAuthor.coAuthoredStories.addObject(currentStory)
                            mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                            })
                        }
                        print("publish story")
                        self.publishStory(currentStory)
                    })
                })

            } else {

                invitedUser = self.users[self.selectedIndex!]
                invitedUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    currentStory.incrementKey(Constants.Story.pageCount)
                    currentStory.pages.append(newPage)
                    currentStory.currentAuthor = invitedUser
                    // Make sure this stuff only gets called once
                    currentStory.allAuthorIds.append(invitedUser.objectId!)
                    currentStory.allAuthors.addObject(invitedUser)
                    // work on local data storage later
                    // currentStory.pinInBackground()
                    currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        let relation: PFRelation = mainAuthor.coAuthoredStories
                        let query = relation.query()
                        query?.whereKey(Constants.Story.objectId, equalTo:currentStory.objectId!)

                        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

                            // add story to author's library if not in there already
                            if objects == nil {
                                mainAuthor.coAuthoredStories.addObject(currentStory)
                                mainAuthor.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                                })
                            }
                            // Assign value to invited User based on user interaction with view
                            let innerQuery = User.query()
                            innerQuery!.whereKey(Constants.User.objectId, equalTo: invitedUser.objectId!)

                            let query = PFInstallation.query()
                            query?.whereKey("user", matchesQuery:innerQuery!)

                            let data = [
                                "alert" : "\(mainAuthor.username!) has added you to a story!",
                                "badge" : "Increment",
                                "s" : "\(currentStory.objectId!)", // Story's object id
                            ]

                            let push = PFPush()
                            push.setQuery(query)
                            push.setData(data)
                            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                if success {
                                    print("successful push")
                                    if currentStory.mainAuthor != mainAuthor{
                                        //self.sendPushToMainAuthor()
                                    }
                                    // TODO: delegation
                                    self.delegate?.didAddNewPage()
                                } else {
                                    print("push failed")

                                }

                                self.goBackHome()

                            })
                        })
                    })
                })
            }
        })

    }

        func publishStory(story: Story) -> Void {
            story.isPublished = true

            story.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                // TODO: delegation here to add story to main feed?

                let innerQuery = User.query()
                innerQuery?.whereKey(Constants.User.objectId, containedIn: story.allAuthorIds)

                let query = PFInstallation.query()
                query?.whereKey("user", matchesQuery:innerQuery!)

                let data = [
                    "alert" : "A story you contibuted to has been published!",
                    "s" : "\(story.objectId!)", // Story's object id
                ]

                let push = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    self.delegate?.didAddNewPage()
                    
                    self.goBackHome()
                    
                })
            }
        }
        
        func goBackHome(){
            
            // not working
            // performSegueWithIdentifier("unwindToHomeScreen", sender: self)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Home") as! HomeViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
        
}







