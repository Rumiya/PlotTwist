//
//  OnboardPageViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/12/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class OnboardPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    let pageTitles = ["Easily start new story", "Send to a friend to have them add to the story", "Share published stories", "Your balloon will let you know if you have been sent a new story", "The friend balloon will appear if you have a new friend request"]
    var images = ["pencil.png","paperPlane.png","share.png","airBallon.png","airBallonFriend.png"]
    var count = 0

    @IBAction func swipeLeft(sender: AnyObject) {
        print("SWipe left")
    }
    @IBAction func swiped(sender: AnyObject) {
        reset()
    }

    func reset() {
       dataSource = self
        delegate = self

        let pageContentViewController = self.viewControllerAtIndex(0)
        self.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        var index = (viewController as! OnboardContentViewController).pageIndex!
        index++
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)

    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        var index = (viewController as! OnboardContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)

    }

    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OnboardContentViewController") as! OnboardContentViewController

        pageContentViewController.imageName = self.images[index]
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {

        if let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("OnboardContentViewController") as? OnboardContentViewController {
            return pageContentViewController.pageIndex!
        }

        return 0
    }


}
