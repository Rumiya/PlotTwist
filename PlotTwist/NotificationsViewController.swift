//
//  NotificationsViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/4/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewPageDelegate {

    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()

    var activeStories: [Story] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func queryForActiveStories() {
        let query = Story.query()
        query?.whereKey(Constants.Story.currentAuthor, equalTo: User.currentUser()!)
        query?.whereKeyExists(Constants.Story.objectId)
        query?.includeKey(Constants.Story.mainAuthor)
        query?.whereKey(Constants.Story.isPublished, equalTo: false)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            self.activeStories = objects as! [Story]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
    }

    override func viewWillAppear(animated: Bool) {
        queryForActiveStories()
        updateBadgeNumber()
    }

    func updateBadgeNumber() {
        if currentInstallation.badge > 0{
            currentInstallation.badge = 0
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tabBarController!.tabBar.items![2].badgeValue = nil
            })
            currentInstallation.saveInBackground()
        } else if currentInstallation.badge == 0 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tabBarController!.tabBar.items![2].badgeValue = nil
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let user = self.activeStories[indexPath.row].mainAuthor
        cell.textLabel?.text = user.username
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeStories.count
    }

    // MARK: - New Page Delegate Methods
    func didAddNewPage(editedStory: Story, nextAuthor: User) {
        dismissViewControllerAnimated(true, completion: nil)
        editedStory.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.queryForActiveStories()
        }
    }

    func didEndStory(endedStory: Story) {
        dismissViewControllerAnimated(true, completion: nil)
        endedStory.isPublished = true
        self.queryForActiveStories()
    }

    func didCancelNewPage() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! AddPageViewController
        vc.currentStory = self.activeStories[(self.tableView.indexPathForSelectedRow?.row)!]
        vc.delegate = self
    }

}
