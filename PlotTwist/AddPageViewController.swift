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
    let invitedUser = User()

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
                file!.saveInBackground()
                newPage.content = file!
            } else {
                // TODO: handle error in data encoding here
            }
            newPage.saveInBackground()

            // Edit Story Properties
            currentStory.incrementKey(Constants.Story.pageCount)
            currentStory.pages.append(newPage)
            // work on local data storage later
            // currentStory.pinInBackground()
            currentStory.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
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

            if (newPage.pageNum == 10) {
                publishStory(currentStory)

            } else {

                // Assign value to invited User based on user interaction with view
                // invitedUser = _________

                let innerQuery = User.query()
                innerQuery!.whereKey(Constants.User.objectId, equalTo: invitedUser.objectId!)

                let query = PFInstallation.query()
                query?.whereKey("user", matchesQuery:innerQuery!)

                let data = [
                    "alert" : "\(author.username) has started a story and invited to you contribute next!",
                    "badge" : "Increment",
                    "s" : "\(currentStory.objectId)", // Story's object id
                ]

                let push = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackground()
            }
        }
    }

    func publishStory(story: Story) -> Void {
        story.isPublished = true

        story.saveInBackground()

        // TODO: delegation here to add story to main feed?
        
        let innerQuery = User.query()
        innerQuery?.whereKey(Constants.User.objectId, containedIn: currentStory.allAuthorIds)

        let query = PFInstallation.query()
        query?.whereKey("user", matchesQuery:innerQuery!)


        let data = [
            "alert" : "A story you contibuted to has been published!",
            "badge" : "Increment",
            "s" : "\(currentStory.objectId)", // Story's object id
        ]

        let push = PFPush()
        push.setQuery(query)
        push.setData(data)
        push.sendPushInBackground()

        dismissViewControllerAnimated(true, completion: nil)
    }

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Make sure you add to the story and select the next author.", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        return cell
    }
}