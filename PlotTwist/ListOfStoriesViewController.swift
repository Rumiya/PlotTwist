//
//  ListOfStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/7/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ListOfStoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //var stories: [Story] = []

    @IBOutlet weak var tableView: UITableView!
    var stories: Array<Story>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stories!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let user = stories![indexPath.row].mainAuthor as User
        cell.textLabel!.text = user.username
        cell.detailTextLabel?.text = stories![indexPath.row].storyTitle
        print(stories![indexPath.row].storyTitle)
        return cell
    }

    @IBAction func unwindToListOfCategories(segue:UIStoryboardSegue) {

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = self.tableView.indexPathForSelectedRow

        let vc = segue.destinationViewController as! ReadStoryViewController
        vc.story = self.stories![index!.row]

    }

}
