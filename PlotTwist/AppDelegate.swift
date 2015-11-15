//
//  AppDelegate.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/2/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit
import Parse
import ParseCrashReporting
import ParseFacebookUtilsV4
import FBSDKCoreKit
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var contactStore = CNContactStore()

    func crash(){
        // Test Crash
        NSException(name: NSGenericException, reason: "Everything is ok. This is just a test crash.", userInfo: nil).raise()

    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Allow local storage
        Parse.enableLocalDatastore()

        // Enable Crash Reporting
        ParseCrashReporting.enable()

        // Initialize Parse
        Parse.setApplicationId("4oB2SxIWEp5ZpyN1J9CqG2K2fzCPHAHL434m5Fel", clientKey: "PZBIaNyNTpEqYwWv8bmqjNi6Aev98qrRX0vwkpab")

        // Track statistics
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

        // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        Story.registerSubclass()
        Page.registerSubclass()
        User.registerSubclass()
       //does this need to be set to uncomment 
        //return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }

        // Crash Testing
        /*
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            { () -> Void in
                self.crash()
        });
        */
//
//        // Extract the notification data
//        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
//
//            // Create a pointer to the Photo object
//            let storyId = notificationPayload["s"] as? String
//            let targetStory = Story(withoutDataWithObjectId: storyId)
//
//            // Fetch photo object
//            targetStory.fetchIfNeededInBackgroundWithBlock {
//                (object: PFObject?, error:NSError?) -> Void in
//                if error == nil {
//
//                    let tabBarController = self.window?.rootViewController as! UITabBarController
//                    let myStoryNC = tabBarController.viewControllers![0] as! UINavigationController
//                    let myStoryVC = myStoryNC.viewControllers[0] as! MyStoriesViewController
//                    
//                    myStoryVC.getAllMyStories()
//                    myStoryNC.pushViewController(myStoryVC, animated: true)
//
////                    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
////
////                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
////
////                    // TODO: Add Storyboard ID to AddPageViewController
////                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("AddPageVC") as! AddPageViewController
////
////                    self.window?.rootViewController = initialViewController
////                    self.window?.makeKeyAndVisible()
//
//                }
//            }
//        }

        // Change navigation bar appearance
        UINavigationBar.appearance().barTintColor = UIColor(red:0.39, green:0.67, blue:0.97, alpha:1.0)

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        if let barFont = UIFont(name: "Noteworthy Light", size: 22.0) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:barFont]
        }

        // Change status bar style
        //UIApplication.sharedApplication().statusBarStyle = .LightContent

        //Remove status bar
        UIApplication.sharedApplication().statusBarHidden = true

        // Change toolbar style
        //    UIBarButtonItem.appearance().tintColor = UIColor(red: 235.0/255.0, green: 73.0/255.0, blue: 27.0/255.0, alpha: 1.0)
        UIToolbar.appearance().barTintColor = UIColor(red:0.39, green:0.67, blue:0.97, alpha:1.0)

        // Change tabbar style
        UITabBar.appearance().tintColor = UIColor.whiteColor()


        UITabBar.appearance().barTintColor = UIColor(red:0.39, green:0.67, blue:0.97, alpha:1.0)

        if User.currentUser() == nil {

            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

            let storyboard = UIStoryboard(name: "Login", bundle: nil)

//            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Login") as! LoginViewController

            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("DoorLogin") as! DoorLoginViewController

            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }


        return true
    }

    func  application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)

    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        if let currentInstallation: PFInstallation = PFInstallation.currentInstallation(){
            currentInstallation.setDeviceTokenFromData(deviceToken)
            currentInstallation.channels = ["global"]
            currentInstallation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    print("successful PFInstallation")
                } else {
                    print("unable to save PFInstallation")
                }
            }
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

        let homeVC = window?.rootViewController as! HomeViewController
        homeVC.getNotificationCount()

        PFPush.handlePush(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {

        if let currentInstallation: PFInstallation = PFInstallation.currentInstallation() {
            if currentInstallation.badge != 0 {
                currentInstallation.badge = 0
                currentInstallation.saveInBackground()
            }
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if User.currentUser() != nil {
            let homeVC = window?.rootViewController as! HomeViewController
            homeVC.getNotificationCount()
        }

        if let currentInstallation: PFInstallation = PFInstallation.currentInstallation() {
            if currentInstallation.badge != 0 {
                currentInstallation.badge = 0
                currentInstallation.saveInBackground()
            }
        }

        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Custom functions

    class func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }


    func showMessage(message: String) {
        let alertController = UIAlertController(title: "PlotTwist", message: message, preferredStyle: UIAlertControllerStyle.Alert)

        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }

        alertController.addAction(dismissAction)

        let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]

        presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    }


    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)

        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)

        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })

        default:
            completionHandler(accessGranted: false)
        }
    }


}

