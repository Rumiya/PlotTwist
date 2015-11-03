//
//  LibraryViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse

class LibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   // @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let query = Story.query()
        query?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)
        query?.whereKey(Constants.Story.isPublished, equalTo: true)
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                // There was an error
            } else {
                // TODO:Assign objects to data variable


            }
        })
    }


}
