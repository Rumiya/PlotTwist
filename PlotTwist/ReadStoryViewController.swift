//
//  ReadStoryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import AVFoundation

class ReadStoryViewController: UIViewController {


    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyContentTextView: UITextView!
    @IBOutlet weak var storyPageView: UIView!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var accentPickerView: UIPickerView!
    @IBOutlet weak var accentButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!


    let languages = ["Arabic","British","Chinese","English USA","Finnish","French","German","Greek","Hebrew","Hindi","Italian","Japanese","Korean","Norwegian","Polish","Portuguese","Romanian","Russian","Spanish","Swedish","Thai","Turkish"]
    let locales = ["ar-SA","en-GB","zh-CN","en-US","fi-FI","fr-FR","de-DE","el-GR","he-IL","hi-IN","it-IT","ja-JP","ko-KR","no-NO","pl-PL","pt-BR","ro-RO","ru-RU","es-ES","sv-SE","th-TH","tr-TR"]


    var selectedStory: Story?
    var pages: Array<Page>?

    var pageNum:Int = 0
    var pagesCount:Int = 0

    var storyContent: String?

    let synthesizer = AVSpeechSynthesizer()
    var pickedLanguage: String?
    let defaults = NSUserDefaults.standardUserDefaults()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitleLabel.text = selectedStory?.storyTitle

        self.previousButton.enabled = false

        pages = selectedStory?.pages

        pagesCount = (pages?.count)!

        let currentPage = pages![0]

        self.getTextViewContent(currentPage)
        self.speakButton.tintColor = UIColor.lightGrayColor()

    }

    override func viewWillAppear(animated: Bool) {
        //speakString((selectedStory?.storyTitle)!)
    }

    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedLanguage = locales[row]
        pickerView.hidden = true
        let pickedLocales = self.defaults.stringForKey("pickedLocales")
        self.defaults.setObject(pickedLanguage, forKey: "pickedLocales")
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
                    self.authorImage.hidden = false
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

    @IBAction func onAccentButtonPressed(sender: UIButton) {

        accentPickerView.hidden = !accentPickerView.hidden

    }
    @IBAction func onSpeakButtonPressed(sender: UIButton) {

        if self.speakButton.tintColor != UIColor.lightGrayColor() {
            pauseSpeaking()
        } else {
            if self.pageNum == 0 {
            speakString((selectedStory?.storyTitle)! + self.storyContentTextView.text)
            } else {
                speakString(self.storyContentTextView.text)
            }
        }
    }

    func speakString(string: String){

        let utterance = AVSpeechUtterance(string: string)

//        if pickedLanguage == nil {
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
//        } else {
//            utterance.voice = AVSpeechSynthesisVoice(language: pickedLanguage)
//        }
        utterance.voice = AVSpeechSynthesisVoice(language: self.defaults.stringForKey("pickedLocales"))
        utterance.rate = 0.5
        synthesizer.speakUtterance(utterance)
        self.speakButton.tintColor = UIColor.blackColor()

    }
    func stopSpeaking() {
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)

    }

    func pauseSpeaking(){
        synthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
        self.speakButton.tintColor = UIColor.lightGrayColor()
    }

    // MARK: Error Controller
    func presentError() {
        let alertController = UIAlertController(title: "Error retrieving data", message: "Check internet connection and try again.", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
    }


    @IBAction func onNextButtonPressed(sender: UIButton) {

        stopSpeaking()
        // increment the value of a page index
        ++self.pageNum

        if self.pageNum < pages?.count {

            let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
            UIView.transitionWithView(self.storyPageView, duration: 1.0, options: transitionOptions, animations: {

                // update the story page content
                self.storyContentTextView.text = ""
                self.authorImage.hidden = true

                //            self.storyContentTextView.viewWithTag(100)?.removeFromSuperview()

                let currentPage = self.pages![self.pageNum]
                self.getTextViewContent(currentPage)

                self.storyContentTextView.text = currentPage.textContent

                }, completion: { finished in

                    // any code entered here will be applied once the animation has completed

                    self.previousButton.enabled = true

                    if self.speakButton.tintColor != UIColor.lightGrayColor() {
                        self.speakString(self.storyContentTextView.text)
                    }
            })

        }

        if self.pageNum == self.pagesCount || self.pageNum == self.pagesCount - 1{
            self.nextButton.enabled = false
        }

    }

    @IBAction func onPreviousButtonPressed(sender: UIButton) {
        stopSpeaking()
        --self.pageNum
        if self.pageNum >= 0 {

            let transitionOptions = UIViewAnimationOptions.TransitionCurlDown
            UIView.transitionWithView(self.storyPageView, duration: 1.0, options: transitionOptions, animations: {

                // update the story page content
                self.storyContentTextView.text = ""
                self.authorImage.hidden = true

                let currentPage = self.pages![self.pageNum]
                self.getTextViewContent(currentPage)

                self.storyContentTextView.text = currentPage.textContent

                }, completion: { finished in
                    self.nextButton.enabled = true
                    if self.speakButton.tintColor != UIColor.lightGrayColor() {
                        self.speakString(self.storyContentTextView.text)
                    }

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

        let index = storyContent.startIndex.advancedBy(525)
        var shortContent = storyContent.substringToIndex(index);
        shortContent += "... To be continued..."

        let image  = self.imageFromString(shortContent, inImage: UIImage(named: "blurBackground")!,  attributes: textAttributes)

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
    
    @IBAction func onBackButtonPressed(sender: UIButton) {
        stopSpeaking()
    }
}
