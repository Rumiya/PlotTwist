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

    var story: Story?
    var pages: Array<Page>?

    var pageNum:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitleLabel.text = story?.storyTitle

        pages = story?.pages

        let currentPage = pages![0]

        self.getTextViewContent(currentPage)
        ++pageNum

    }

    func getTextViewContent(page: Page){
        let user = page.author 
        // Set a user image
        do {
            try user.fetchIfNeeded()

            let username = user.username
            let usernameImage = getUsernameFirstLetterImagename(username!)

        if ((UIImage(named:usernameImage)) != nil){

//        let image = UIImageView(image: UIImage(named: usernameImage))
//        image.layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            image.tag = 100

        self.authorImage.image = UIImage(named: usernameImage)
        let path = UIBezierPath(rect: CGRectMake(0, 0, 60, 50))
        self.storyContentTextView.textContainer.exclusionPaths = [path]
       // self.storyContentTextView.addSubview(image)

        }
        self.storyContentTextView.text = page.textContent

        } catch _ {
            print("There was an error")
        }


    }

    @IBAction func onNextButtonPressed(sender: UIButton) {

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

                // increment the value of a page index
                ++self.pageNum
        })

        } else {

            self.nextButton.enabled = false

        }

    }





    // Add after merge
//    @IBAction func onShareButtonPressed(sender: UIButton) {
//
//        var storyContent:String = ""
//
//        for page in pages! {
//            storyContent = storyContent + page.textContent + "\n"
//        }
//        print(storyContent)
//        let textToShare = storyContent
//        let objectsToShare = [textToShare]
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
//        self.presentViewController(activityVC, animated: true, completion: nil)
//
//    }
//
//    func imageFromString(string: String, attributes: Dictionary, size: CGSize) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

//    return image;
//    }

}
