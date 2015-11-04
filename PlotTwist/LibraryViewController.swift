//
//  LibraryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var stories: [Story] = []
    var story: Story = Story()


    override func viewDidLoad() {
        super.viewDidLoad()
        story = stories.first!
        tableView.reloadData()

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCellWithIdentifier("TableCell")!


        return tableCell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! LibraryCollectionViewCell

        let pages = story.pages

        let pageContent = pages[indexPath.item].content

        pageContent.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
            collectionCell.textView.text = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
        })

        return collectionCell

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return story.pageCount
    }
}
