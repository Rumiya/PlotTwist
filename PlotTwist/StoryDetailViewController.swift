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
    override func viewDidLoad() {
        super.viewDidLoad()

        let query = Story.query()
        query?.includeKey(Constants.Story.pages)
        query?.whereKey(Constants.Story.objectId, equalTo: story.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

            let myStory = objects?.first as! Story

            let pageQuery = Page.query()
            pageQuery?.whereKey(Constants.Page.story, equalTo: myStory)
            pageQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

                let pages = objects as! [Page]
                if pages.count > 0 {
                    let firstPage: Page = pages[0]
                    let pageContent = firstPage.content
                    pageContent.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                        self.contentTextField.text = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
                    })
                } else {
                    self.contentTextField.text = ""
                    print("no pages in the story")
                }
                
                
            })

            })



    }


    @IBOutlet weak var onSettingsButtonPressed: UIButton!

    @IBAction func onSettingsButtonPressed(sender: UIButton) {

    }

    @IBAction func onDeleteButtonPressed(sender: UIButton) {

        let alertController = UIAlertController(title: "Delete Story", message: "Are you sure?", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .Destructive) { (action: UIAlertAction) -> Void in
            for page in self.story.pages {
                page.deleteInBackground()
            }
            self.story.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

                self.navigationController?.popViewControllerAnimated(true)

                // WARNING: need to figure out how much to delete with pointers to the story



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
