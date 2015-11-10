//
//  InboxViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/10/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:InboxTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! InboxTableViewCell

        // TO DO: add meat


        // Set a different cell background color for odd / even rows
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = UIColor(red:0.76, green:0.91, blue:0.98, alpha:1.0)
        } else {
            cell.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.74, alpha:1.0)
        }

        // Set selected cell background color the same as the cell background. Otherwise it will be gray
        let cellBGView = UIView()
        cellBGView.backgroundColor = cell.backgroundColor
        cell.selectedBackgroundView = cellBGView
        
        return cell
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
