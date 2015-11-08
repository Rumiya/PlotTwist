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
    @IBOutlet weak var nextButton: UIButton!

    var story: Story?

    var pageNum:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitleLabel.text = story?.storyTitle

        let pages = story?.pages
        self.storyContentTextView.text = pages![pageNum].textContent
        ++pageNum

    }

    @IBAction func onNextButtonPressed(sender: UIButton) {

        let pages = story?.pages

        if self.pageNum < pages?.count {

        let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
        UIView.transitionWithView(self.storyPageView, duration: 2.0, options: transitionOptions, animations: {

            // update the story page content
            self.storyContentTextView.text = ""
            self.storyContentTextView.text = pages![self.pageNum].textContent


            }, completion: { finished in

                // any code entered here will be applied
                // .once the animation has completed

                // increment the value of a page index
                ++self.pageNum
        })

        } else {

            self.nextButton.enabled = false

        }

    }

}
