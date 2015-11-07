//
//  UserStatisticsViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/6/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class UserStatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
    NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell",
    forIndexPath: indexPath) as! UserStatisticsTableViewCell

    // Configure the cell...
    switch indexPath.row {
    case 0:
        cell.typeLabel.text = "My Published Stories"
        cell.countLabel.text = ""
    case 1:
        cell.typeLabel.text = "Still Twisting"
        cell.countLabel.text = ""
    case 2:
        cell.typeLabel.text = "Co-authored Stories"
        cell.countLabel.text = ""
    case 3:
        cell.typeLabel.text = ""
        cell.countLabel.text = ""
    default:
        cell.typeLabel.text = ""
        cell.countLabel.text = ""
    }

        return cell
    }

    @IBAction func onSettingsButtonPressed(sender: UIButton) {
    }

    @IBAction func onLogOutButtonPressed(sender: UIButton) {

    User.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
    dispatch_async(dispatch_get_main_queue(), { () -> Void in

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        self.presentViewController(vc, animated: true, completion: nil)

        })
    }

    }

 }
