//
//  ComposeViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/6/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var story: Story?
    var isNewStory: Bool?

    var homeVC: HomeViewController!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!

    @IBOutlet weak var contentTextView: UITextView!

    @IBOutlet weak var previousContentTextView: UITextView!

    //MARK - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        if isNewStory == true {
            previousContentTextView.hidden = true
            titleTextField.hidden = false

        } else {
//            getPreviousPageContent()
            
            previousContentTextView.hidden = false
            titleTextField.hidden = true
            headerLabel.text = story?.storyTitle
            headerLabel.sizeToFit()
        }
    }

    //Mark Query
/*
    func getPreviousPageContent() {
        let query = Story.query()
        query?.includeKey(Constants.Story.pages)
        query?.whereKey(Constants.Story.objectId, equalTo: story!.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

            let myStory = objects?.first as! Story

            let recentPage: Page = myStory.pages.last!

            self.previousContentTextView.text = recentPage.textContent
        })
    }
*/

    //MARK - Text First Responder

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }

    func textViewDidBeginEditing(textView: UITextView) {
        contentTextView.text = ""
    }

    //MARK - segue

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Empty field(s)", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func onNextButtonPressed(sender: AnyObject) {

        if isNewStory == true {
            if (titleTextField.text == nil || contentTextView.text == nil) {
                presentEmptyFieldAlertController()
            } else {
                performSegueWithIdentifier("ToSendSegue", sender: sender)
            }
        } else {
            if (contentTextView.text == nil) {
                presentEmptyFieldAlertController()
            } else {
                performSegueWithIdentifier("ToSendSegue", sender: sender)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ToSendSegue" {
            let vc = segue.destinationViewController as! SendToViewController
            vc.story = story
            vc.isNewStory = isNewStory
            vc.delegate = homeVC

            if isNewStory == true {

                vc.storyTitle = titleTextField.text
                vc.storyContent = contentTextView.text

            } else {
                vc.storyContent = contentTextView.text
                
            }
        }
    }

    @IBAction func unwindToComposeScreen(segue:UIStoryboardSegue) {

    }

}
