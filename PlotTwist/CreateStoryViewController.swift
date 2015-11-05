//
//  CreateStoryViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/4/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class CreateStoryViewController: UIViewController {

    var previousVC: MyStoriesViewController!

    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!

    var newStory: Bool!

    let author = User.currentUser()!
    var currentStory: Story!
    var newPage = Page()

    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(animated: Bool) {
        if (newStory == true) {
            self.textView.hidden = true
        } else {
            self.textView.hidden = false
            getPreviousPageContent()
        }
    }

    func getPreviousPageContent() {
        let query = Story.query()
        query?.includeKey(Constants.Story.pages)
        query?.whereKey(Constants.Story.objectId, equalTo: currentStory.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

            let myStory = objects?.first as! Story

            let recentPage: Page = myStory.pages.last!
            let pageContent = recentPage.content
            pageContent.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.textView.text = (NSString(data:data!, encoding:NSUTF8StringEncoding) as! String)
                })
            })

//            let pageQuery = Page.query()
//            pageQuery?.whereKey(Constants.Page.story, equalTo: myStory)
//            pageQuery?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
//
//                let pages = objects as! [Page]
//                if pages.count > 0 {
//                    let recentPage: Page = pages.last!
//                    let pageContent = recentPage.content
//                    pageContent.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
//                        self.textView.text = (NSString(data:data!, encoding:NSUTF8StringEncoding) as! String)
//                    })
//                } else {
//                    self.textView.text = ""
//                    print("no pages in the story")
//                }
//            })
        })
    }

    init(story: Story?) {
        currentStory = story
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if newStory == true {
            if (storyNameTextField.text == nil || contentTextField.text == nil) {
                presentEmptyFieldAlertController()
                return false
            }
        } else {
            if (contentTextField.text == nil) {
                presentEmptyFieldAlertController()
                return false
            }
        }


        return true
    }

    func presentEmptyFieldAlertController() -> Void {
        // Remind user to enter content before saving
        let alertController = UIAlertController(title: "Incomplete", message: "Empty field(s)", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        storyNameTextField.resignFirstResponder()
        contentTextField.resignFirstResponder()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToSelectAuthorSegue" {
            let vc = segue.destinationViewController as! AddStoryViewController
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
//            let myStoryNC = tabBarController.viewControllers![0] as! UINavigationController
//            let myStoryVC = myStoryNC.viewControllers[0] as! MyStoriesViewController
            vc.delegate = previousVC
            vc.storyTitle = storyNameTextField.text
            vc.storyContent = contentTextField.text
            vc.newStory = newStory
            vc.currentStory = currentStory
        }
    }


}
