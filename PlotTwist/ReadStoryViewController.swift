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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitleLabel.text = selectedStory?.storyTitle
        self.previousButton.enabled = false

        pages = selectedStory?.pages

        pagesCount = (pages?.count)!

        let currentPage = pages![0]

        self.getTextViewContent(currentPage)

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
        
        var storyContent:String =  "\n" + "      Title: " +  (pages?.first?.story.storyTitle)! + "\n"
         for page in pages! {
       
            page.author.fetchIfNeededInBackgroundWithBlock({ (object: PFObject?, error:NSError?) -> Void in
       
                
                    let storyAuthour = page.author.username! + ":  "
                
                   storyContent = storyContent + "\n" + storyAuthour.capitalizedString + page.textContent + "\n"
            })
    
        }
        print(storyContent)
        
//        let textAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.blackColor(), NSBackgroundColorAttributeName: self.UIColorFromRGB(0xb6ebe3)]
//
   let textAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.blackColor(), NSBackgroundColorAttributeName: UIColor.clearColor()]
        
        
  let imageSize: CGRect = CGRectMake(0, 0, self.storyContentTextView.bounds.size.width, self.storyContentTextView.bounds.size.height+70)
        let image  = self.imageFromString(storyContent, attributes: textAttributes, size: imageSize.size)
        
        let textToShare = image
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        self.presentViewController(activityVC, animated: true, completion: nil)
        

    }


    func imageFromString(string: String, attributes: [String : AnyObject], size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        string.drawInRect(CGRectMake(0, +35, size.width, size.height), withAttributes: attributes)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

   }
