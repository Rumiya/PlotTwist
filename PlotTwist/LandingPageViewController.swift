//
//  LandingPageViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/5/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if User.currentUser() == nil
        {
            print("Not logged in..")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! LoginViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })

        } else {

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyStories") as! MyStoriesViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            })
            
        }    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
