//
//  User.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import Parse


class User: PFUser {

    @NSManaged var fullName: String
    @NSManaged var profilePicture: PFFile
    @NSManaged var friends: PFRelation
    @NSManaged var viewedStories: PFRelation
    @NSManaged var votedStories: PFRelation
    @NSManaged var authoredStories: PFRelation
    @NSManaged var coAuthoredStories: PFRelation
    @NSManaged var invitedStories: PFRelation

    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    
    //Signing Up
    class func myMethod() {
        let user = User()
        user.username = "myUsername"
        user.password = "myPassword"
        user.email = "email@example.com"
        // other fields can be set just like with PFObject
        
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                
            // Show the errorString somewhere and let the user try again.
            } else {
                
                // Hooray! Let them use the app now.
                PFUser.logInWithUsernameInBackground("myUsername", password:"myPassword") {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil {
                        // Do stuff after successful login.
                    } else {
                        // The login failed. Check error to see why.
                    }
                    
                }
            }
        }
    }
    
    

}
