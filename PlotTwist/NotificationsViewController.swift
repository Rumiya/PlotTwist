//
//  NotificationsViewController.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/4/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if currentInstallation.badge > 0{
            currentInstallation.badge = 0
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tabBarController!.tabBar.items![2].badgeValue = nil
            })
            currentInstallation.saveInBackground()
        } else if currentInstallation.badge == 0 {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tabBarController!.tabBar.items![2].badgeValue = nil
            })
        }
    }

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
