//
//  MyStoriesViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import ParseFacebookUtilsV4

class MyStoriesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if User.currentUser() == nil
        {
            print("Not logged in..")

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(viewController, animated: true, completion: nil)
            })

        } else {
            print("Logged in")
            if (FBSDKAccessToken.currentAccessToken() != nil) {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, friends, picture"]).startWithCompletionHandler({ (connection, result, error) in
                    if (error != nil) { return }
                    if let fbUser = result as? NSDictionary {
                        let email = fbUser.objectForKey("email") as? String
                        let username = fbUser.objectForKey("name") as? String
                       // let facebookID:String = (fbUser.objectForKey("id") as? String)!

                        let user = User.currentUser()
                        user!.email = email
                        user!.username = username
                        user!.saveInBackground()

                    }
                })
            }

        }


        // Do any additional setup after loading the view.
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        return cell
    }

    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath)
        -> UICollectionReusableView {

            switch kind {
                //2
            case UICollectionElementKindSectionHeader:
                //3
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "Header",
                    forIndexPath: indexPath)
                    
                return headerView
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }


    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
    }
    
    @IBAction func onNotificationsButtonPressed(sender: UIBarButtonItem) {
    }
}
