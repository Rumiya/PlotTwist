//
//  SendToViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/6/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class SendToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var story: Story?
    var page: Page?
    var users: Array<User>?

    var storyTitle: String?
    var storyContent: String?

    var selectedIndex: Int?

    @IBOutlet weak var headerLabel: UILabel!
    
    var isNewStory: Bool?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        let query = User.query()
        query?.whereKey(Constants.User.objectId, notEqualTo: (User.currentUser()?.objectId)!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.users = objects as? [User]
                print(" no error  ")
                self.tableView.reloadData()
            } else {
                print("error retrieving")
            }
        })

        if isNewStory == false {
            if story!.pageCount == 4 {
                self.tableView.hidden = true
                self.headerLabel.text = "Last Page!"
            }
        }

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.users?.count)!
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel?.text = self.users![indexPath.row].username
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

    }
 }
