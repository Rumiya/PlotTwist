//
//  ListOfStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import MessageUI

class ListOfStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

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

// MARK: Table View Delegate Methods

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        let user = self.stories![indexPath.row].mainAuthor as User

        let reportAction = UITableViewRowAction(style: .Default, title: "Report") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let alertController = UIAlertController(title: "Report Story?", message: "This action will remove the story from your collection.", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction) -> Void in

                User.currentUser()!.reportedStories.append(self.stories![indexPath.row].objectId!)
                User.currentUser()!.saveInBackgroundWithBlock({ (result: Bool, error: NSError?) -> Void in
                    self.stories?.removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
                })

                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["apps.plottwist@gmail.com"])
                    mail.setMessageBody("<p>Story ID: \(self.stories![indexPath.row].objectId!)</p>", isHTML: true)
                    mail.setSubject("PlotTwist User Reported Story")
                    self.presentViewController(mail, animated: true, completion: nil)
                } else {
                    let failureAlertController = UIAlertController(title: "Email Failed", message: "Unable to open email service at this time.", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    failureAlertController.addAction(okAction)
                    self.presentViewController(failureAlertController, animated: true, completion: nil)
                }
            })
            let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        reportAction.backgroundColor = UIColor.grayColor()
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
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


        if user.objectId == User.currentUser()?.objectId {
            return [deleteAction]
        } else {
            return [reportAction]
        }
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if (editingStyle == UITableViewCellEditingStyle.Delete) {
//            // handle delete (by removing the data from your array and updating the tableview)
//
//            let user = stories![indexPath.row].mainAuthor as User
//            if user.objectId == User.currentUser()?.objectId {
//
//                let objectToDel: PFObject = self.stories![indexPath.row]
//
//                objectToDel.deleteInBackgroundWithBlock({ (succeeded: Bool, error:NSError?) -> Void in
//                    self.stories?.removeAtIndex(indexPath.row)
//
//                    let alertController = UIAlertController(title: "Delete", message: "The story was deleted successfully", preferredStyle: .Alert)
//                    let action = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction) -> Void in
//
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            self.tableView.reloadData()
//                        })
//                        
//                    })
//                    
//                    alertController.addAction(action)
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                })
//            }
//        }
    }
}




