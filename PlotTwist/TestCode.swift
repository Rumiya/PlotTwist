//
//  TestCode.swift
//  PlotTwist
//
//  Created by Philip Henson on 11/3/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation

// TESTING PUSH NOTIFICATIONS

//        let innerQuery = User.query()
//        innerQuery!.whereKey(Constants.User.objectId, equalTo: "OQZcfCWoBp")
//
//        let query = PFInstallation.query()
//        query?.whereKey("user", matchesQuery:innerQuery!)
//
//        let data = [
//            "alert" : "Hey Lin, this is a push notification!",
//            "s" : "storyID", // Story's object id
//        ]
//
//        let push = PFPush()
//        push.setQuery(query)
//        push.setData(data)
//        push.sendPushInBackground()

//TESTING USER SIGNUP
/*
let user = User()
user.username = "linsanity"
user.password = "myPassword"
user.email = "linsanity@example.com"
// other fields can be set just like with PFObject


user.signUpInBackgroundWithBlock {
(succeeded: Bool, error: NSError?) -> Void in
if error != nil {

// Show the errorString somewhere and let the user try again.
} else {

// Hooray! Let them use the app now.
PFUser.logInWithUsernameInBackground("linsanity", password:"myPassword") {
(user: PFUser?, error: NSError?) -> Void in
if user != nil {

//PFPush.sendPushMessageToChannelInBackground("global", withMessage: "tesing push notifications")

let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
currentInstallation.setObject(User.currentUser()!, forKey: "user")
currentInstallation.saveInBackground()


let innerQuery = User.query()
innerQuery!.whereKey(Constants.User.objectId, equalTo: "NxIG14eA5c")

let query = PFInstallation.query()
query?.whereKey("user", matchesQuery:innerQuery!)

let data = [
"alert" : "Testing push notifications!",
"s" : "storyID", // Story's object id
]

let push = PFPush()
push.setQuery(query)
push.setData(data)
push.sendPushInBackground()


self.getAllMyStories()
// Do stuff after successful login.
} else {
// The login failed. Check error to see why.
}

}
}
}
*/

/* work on local storage later

// First check local datastore

let queryLocalData = Story.query()
queryLocalData?.fromLocalDatastore()
queryLocalData?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)

queryLocalData?.findObjectsInBackground().continueWithBlock({ (task: BFTask!) -> AnyObject! in
if task.error != nil {
return task
}

self.stories = task.result as! [Story]
for story in self.stories {
self.totalVotes = self.totalVotes + story.voteCount
}
// TODO: outlet collection view
// collectionView.reloadData()
// also update vote count


// Not Check For Any New Data From Parse
let query = Story.query()
query?.whereKey(Constants.Story.mainAuthor, equalTo: User.currentUser()!)

// Query for new results from the network
query?.findObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
return Story.unpinAllObjectsInBackgroundWithName("MyStories").continueWithSuccessBlock({ (ignored: BFTask!) -> AnyObject! in

// Cache new results
let updatedStories = task.result as! [Story]

if updatedStories.count != self.stories.count {
self.stories = updatedStories
for story in self.stories {
self.totalVotes = self.totalVotes + story.voteCount
}
// TODO: outlet collection view
// collectionView.reloadData()
// also update vote count
}
return Story.pinAllInBackground(updatedStories, withName: "MyStories")

})
})

return task


})

*/

