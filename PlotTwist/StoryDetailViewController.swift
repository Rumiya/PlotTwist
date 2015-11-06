//
//  StoryDetailViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class StoryDetailViewController: UIViewController {

    @IBOutlet weak var contentTextField: UITextView!
    var story: Story = Story()
    var delegate: DeleteStoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        self.contentTextField.text = ""

        let query = Story.query()
        query?.includeKey(Constants.Story.pages)
        query?.whereKey(Constants.Story.objectId, equalTo: story.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

            let myStory = objects?.first as! Story
            self.navigationController?.navigationItem.title = myStory.storyTitle

            for page in myStory.pages {
                self.contentTextField.text = "\(page.pageNum): " + self.contentTextField.text + page.textContent + "\n"

            }

        })
    }

    @IBAction func onShareStoryButtonPressed(sender: UIBarButtonItem) {
        let textToShare = "Check out this story"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    @IBAction func onSettingsButtonPressed(sender: UIButton) {
    }
    
    @IBAction func onDeleteButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Remove Story", message: "Are you sure?", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .Destructive) { (action: UIAlertAction) -> Void in
            self.story.allAuthors.removeObject(User.currentUser()!)
            self.story.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                // TODO: resetup delegation
                self.delegate?.didDeleteStory()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)

    }

    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
    }

    @IBAction func unwindToStoryDetail(sender:UIStoryboardSegue) {
        
    }
}
