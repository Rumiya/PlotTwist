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

    var previousContentText: String?

    //MARK - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        if isNewStory == true {
            previousContentTextView.hidden = true
            titleTextField.hidden = false

        } else {

            previousContentTextView.hidden = false
            previousContentTextView.text = previousContentText

            titleTextField.hidden = true
            headerLabel.text = "Page \(story!.pageCount) out 5. \(story!.storyTitle)"
            headerLabel.sizeToFit()
        }
    }

    @IBAction func onBackButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
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
        if contentTextView.text == "Type your story here"{
            contentTextView.text = ""
        }
    }

    //first option
    /*
    func textView(aTextView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let newTextLength: Int = aTextView.text.characters.count - range.length + text.characters.count
    if newTextLength > 160 {
    return false
    }
    //        countLabel.text = "\(newTextLength)"
    return true
    }
    */

    //second option
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if (range.length + range.location >  textField.text?.characters.count) {
            return false;
        }

        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length

        if newLength == 25 {
            let alertController = UIAlertController(title: "Max Character", message: "Title must be less than 25 characters", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        }

        return newLength <= 25
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
