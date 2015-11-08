//
//  CategoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    var storiesToSend: [Story] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onAllButtonPressed(sender: UIButton) {

        let queryPublished = Story.query()
        queryPublished?.whereKey(Constants.Story.isPublished, equalTo: true)
        queryPublished?.whereKeyExists(Constants.Story.objectId)
        queryPublished?.includeKey(Constants.Story.pages)
        queryPublished?.includeKey(Constants.Story.mainAuthor)
        queryPublished?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if objects != nil {
                self.storiesToSend = objects as! [Story]
                self.performSegueWithIdentifier("ToListOfStoriesSegue", sender: self)
            }
        })
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToListOfStoriesSegue"{
            let vc = segue.destinationViewController as! ListOfStoriesViewController
            vc.stories = self.storiesToSend
        }
    }

    @IBAction func unwindToCategories(segue:UIStoryboardSegue) {

    }


}
