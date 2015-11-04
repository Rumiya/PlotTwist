//
//  ExploreViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!


    var storiesToSend: [Story] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func updateWithNewStory(){
        self.collectionView.reloadData()
    }

    func getAllStories() {
        let queryPublished = Story.query()
        queryPublished?.whereKey(Constants.Story.isPublished, equalTo: true)
        queryPublished?.whereKeyExists(Constants.Story.objectId)
        queryPublished?.includeKey(Constants.Story.pages)
        queryPublished?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            self.storiesToSend = objects as! [Story]
            self.performSegueWithIdentifier("ToLibrarySegue", sender: self)
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        // Configure the cell
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if indexPath.item == 0 {
            getAllStories()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

            let vc = segue.destinationViewController as! LibraryViewController
            vc.stories = self.storiesToSend

    }

}
