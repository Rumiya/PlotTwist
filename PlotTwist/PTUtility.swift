//
//  PTUtility.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/8/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import UIKit
import Parse

class PTUtiltiy {
    
    class func friendUserInBackground(user: User, completion:(result: Bool) ->Void) {
        if user.objectId == User.currentUser()?.objectId {
            return
        }

        // Create Activity Object
        let friendActivity = Activity()
        friendActivity.setObject(User.currentUser()!, forKey: Constants.Activity.fromUser)
        friendActivity.setObject(user, forKey: Constants.Activity.toUser)
        friendActivity.setObject(Constants.Activity.Type.friend, forKey: Constants.Activity.type)
        friendActivity.setObject(Constants.Activity.Requests.outgoing, forKey: Constants.Activity.requestType)
        friendActivity.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in

            // Send push notification to user
            let innerQuery = User.query()
            innerQuery!.whereKey(Constants.User.objectId, equalTo:user.objectId!)

            let query = PFInstallation.query()
            query?.whereKey("user", matchesQuery:innerQuery!)
            let data = [
                "alert" : "\(User.currentUser()!.username!) has sent you a friend request!",
                "badge" : "Increment",
                "a" : "\(User.currentUser()!.objectId)", // current user's object id
            ]

            let push = PFPush()
            push.setQuery(query)
            push.setData(data)
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                completion(result: success)
            })
        })
    }

    class func acceptFriendInBackground(user: User, completion:(result: Bool) ->Void) {
        if user.objectId == User.currentUser()?.objectId {
            return
        }


        let activityOneQuery = Activity.query()
        activityOneQuery?.whereKey(Constants.Activity.fromUser, equalTo: user)
        activityOneQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)

        let activityTwoQuery = Activity.query()
        activityTwoQuery?.whereKey(Constants.Activity.toUser, equalTo: user)
        activityTwoQuery?.whereKey(Constants.Activity.fromUser, equalTo: User.currentUser()!)


        let activityQuery = PFQuery.orQueryWithSubqueries([activityOneQuery!, activityTwoQuery!])
        activityQuery.whereKey(Constants.Activity.requestType, equalTo: Constants.Activity.Requests.outgoing)
        activityQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            let activity = objects?.first as! Activity

            activity.setObject(Constants.Activity.Requests.confirmed, forKey: Constants.Activity.requestType)
            activity.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in

                // Not working well right now, not sure why. Also relation is not even being used right now.
//                User.currentUser()!.friends.addObject(user)
//                User.currentUser()!.saveInBackground()
                // Send push notification to user
                let innerQuery = User.query()
                innerQuery!.whereKey(Constants.User.objectId, equalTo:user.objectId!)

                let query = PFInstallation.query()
                query?.whereKey("user", matchesQuery:innerQuery!)
                let data = [
                    "alert" : "\(User.currentUser()!.username!) has accepted your friend request!",
                    "badge" : "Increment",
                    "a" : "\(User.currentUser()!.objectId)", // current user's object id
                ]

                let push = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    completion(result: success)
                })
            }

        })


    }

    class func unFriendUserInBackground(user: User, completion:(result: Bool) ->Void) {
        if user.objectId == User.currentUser()?.objectId {
            return
        }
        let activityOneQuery = Activity.query()
        activityOneQuery?.whereKey(Constants.Activity.fromUser, equalTo: user)
        activityOneQuery?.whereKey(Constants.Activity.toUser, equalTo: User.currentUser()!)

        let activityTwoQuery = Activity.query()
        activityTwoQuery?.whereKey(Constants.Activity.toUser, equalTo: user)
        activityTwoQuery?.whereKey(Constants.Activity.fromUser, equalTo: User.currentUser()!)

        let activityQuery = PFQuery.orQueryWithSubqueries([activityOneQuery!, activityTwoQuery!])
        activityQuery.whereKey(Constants.Activity.requestType, equalTo: Constants.Activity.Requests.confirmed)
        activityQuery.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in

            let activity = objects?.first as! Activity

            activity.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                User.currentUser()!.friends.removeObject(user)
//                User.currentUser()?.saveInBackground()
                completion(result: success)
            }

        })

    }
}