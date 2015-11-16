//
//  ReadStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ReadStoryViewController: UIViewController {


    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyContentTextView: UITextView!
    @IBOutlet weak var storyPageView: UIView!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!

    var selectedStory: Story?
    var pages: Array<Page>?

    var pageNum:Int = 0
    var pagesCount:Int = 0

    var storyContent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitleLabel.text = selectedStory?.storyTitle
        self.previousButton.enabled = false

        pages = selectedStory?.pages

        pagesCount = (pages?.count)!

        let currentPage = pages![0]

        self.getTextViewContent(currentPage)


    }

    override func viewWillAppear(animated: Bool) {

    }

    func getTextViewContent(page: Page){

        page.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
            let user = page.author
            // Set a user image

            let username = user.username
            let usernameImage = getUsernameFirstLetterImagename(username!)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if ((UIImage(named:usernameImage)) != nil){
                    self.authorImage.image = UIImage(named: usernameImage)
                    let path = UIBezierPath(rect: CGRectMake(0, 0, 60, 50))
                    self.storyContentTextView.textContainer.exclusionPaths = [path]
                }
                self.storyContentTextView.text = page.textContent
            })
            } else {
                if let error = error {
                    if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                        print("Uh oh, we couldn't even connect to the Parse Cloud!")
                    } else {
                        let errorString = error.userInfo["error"] as? NSString
                        print("Error: \(errorString)")

                    }
                    self.presentError()
                }
            }
        }
    }

    // MARK: Error Controller
    func presentError() {
        let alertController = UIAlertController(title: "Error retrieving data", message: "Check internet connection and try again.", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func onNextButtonPressed(sender: UIButton) {

        // increment the value of a page index
        ++self.pageNum

        if self.pageNum < pages?.count {

            let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
            UIView.transitionWithView(self.storyPageView, duration: 1.0, options: transitionOptions, animations: {

                // update the story page content
                self.storyContentTextView.text = ""

                //            self.storyContentTextView.viewWithTag(100)?.removeFromSuperview()

                let currentPage = self.pages![self.pageNum]
                self.getTextViewContent(currentPage)

                self.storyContentTextView.text = currentPage.textContent


                }, completion: { finished in

                    // any code entered here will be applied once the animation has completed

                    self.previousButton.enabled = true
            })

        }

        if self.pageNum == self.pagesCount || self.pageNum == self.pagesCount - 1{
            self.nextButton.enabled = false
        }

    }

    @IBAction func onPreviousButtonPressed(sender: UIButton) {

        --self.pageNum
        if self.pageNum >= 0 {

            let transitionOptions = UIViewAnimationOptions.TransitionCurlDown
            UIView.transitionWithView(self.storyPageView, duration: 1.0, options: transitionOptions, animations: {

                // update the story page content
                self.storyContentTextView.text = ""

                let currentPage = self.pages![self.pageNum]
                self.getTextViewContent(currentPage)

                self.storyContentTextView.text = currentPage.textContent

                }, completion: { finished in
                    self.nextButton.enabled = true
            })

        } else {

            self.previousButton.enabled = false

        }

        if self.pageNum == 0 || self.pageNum == -1{
            self.previousButton.enabled = false
        }

    }
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    @IBAction func onShareButtonPressed(sender: UIButton) {

        var storyContent =  "\n" +  (pages?.first?.story.storyTitle)! + "\n"
        for page in pages! {
            storyContent = storyContent + "\n" + page.textContent + "\n"
        }

        let textAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: "Noteworthy", size: 14.0)!, NSForegroundColorAttributeName: UIColor.blackColor(), NSBackgroundColorAttributeName: UIColor.clearColor()]

        let image  = self.imageFromString(storyContent, inImage: UIImage(named: "blurBackground")!,  attributes: textAttributes)

        let textToShare = image
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        self.presentViewController(activityVC, animated: true, completion: nil)

    }


    func imageFromString(string: String, inImage:UIImage, attributes: [String : AnyObject]) -> UIImage {
        UIGraphicsBeginImageContext(inImage.size)
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        let rect: CGRect = CGRectMake(20, 10, inImage.size.width-40, inImage.size.height-80)
        
        string.drawInRect(rect, withAttributes: attributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
