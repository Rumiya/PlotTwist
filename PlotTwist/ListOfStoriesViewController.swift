//
//  ListOfStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ListOfStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var stories: Array<Story>?
    //var isOdd: Bool

    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.estimatedRowHeight = 80.0
        //        tableView.rowHeight = UITableViewAutomaticDimension

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:ListOfStoriesTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListOfStoriesTableViewCell

        // Display a user name and a story title
        let user = stories![indexPath.row].mainAuthor

        user.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in



        }

        cell.authorLabel.text = user.username

        cell.storyTitleLabel.text = stories![indexPath.row].storyTitle

        // Set a user image
        let usernameImage = getUsernameFirstLetterImagename(user.username!)

        if ((UIImage(named:usernameImage)) != nil){

            cell.userImage.image = UIImage(named:usernameImage)
        }

        // Set a different cell background color for odd / even rows
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(red:0.76, green:0.91, blue:0.98, alpha:1.0)
        } else {
            cell.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.74, alpha:1.0)
        }

        // Set selected cell background color the same as the cell background. Otherwise it will be gray
        let cellBGView = UIView()
        cellBGView.backgroundColor = cell.backgroundColor
        cell.selectedBackgroundView = cellBGView

        return cell
    }

    @IBAction func unwindToListOfStories(segue:UIStoryboardSegue) {

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ToReadStorySegue"{
            let index = self.tableView.indexPathForSelectedRow
            let vc = segue.destinationViewController as! ReadStoryViewController
            vc.selectedStory = self.stories![index!.row]
        }

    }

    //added swipe to delete table cell

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)

            let user = stories![indexPath.row].mainAuthor as User
            if user.objectId == User.currentUser()?.objectId {

                let objectToDel: PFObject = self.stories![indexPath.row]

                objectToDel.deleteInBackgroundWithBlock({ (succeeded: Bool, error:NSError?) -> Void in
                    self.stories?.removeAtIndex(indexPath.row)

                    let alertController = UIAlertController(title: "Delete", message: "The story was deleted successfully", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction) -> Void in

                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                        
                    })
                    
                    alertController.addAction(action)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
}




