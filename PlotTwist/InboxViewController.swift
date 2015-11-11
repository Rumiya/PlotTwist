//
//  InboxViewController.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/10/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import UIKit



class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    //add a tableView outlet
    @IBOutlet weak var tableView: UITableView!
    
    var story: Story?
    var isNewStory: Bool?
    var homeVC: HomeViewController!
    
     var incomingStoryPageArray: [Page] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return incomingStoryPageArray.count
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
        
        
        //copied code
        
        let page: Page = self.incomingStoryPageArray[indexPath.row]
   
      
        page.author.fetchIfNeededInBackgroundWithBlock({ (object: PFObject?, error:NSError?) -> Void in
    cell.authorLabel.text =  page.author.username
    
    let usernameImage = getUsernameFirstLetterImagename(page.author.username!)
    
    if ((UIImage(named:usernameImage)) != nil){
        
        cell.authorImage.image = UIImage(named:usernameImage)
    }
    
})
    
//        if (page.author.username != nil) {
//             cell.authorLabel.text = page.author.username
//        }
      
        cell.dateCreatedLabel.text =  PTUtiltiy.getElapsedTimeFromDate(page.createdAt!)
        cell.previousContent.text = page.textContent
        
     
        
  
        return cell
    }
    



   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        
        if segue.identifier == "ToComposePageSegue" {
            let vc = segue.destinationViewController as! ComposeViewController
           
            let indexPath = tableView.indexPathForSelectedRow
            
       let page: Page = incomingStoryPageArray[indexPath!.row]
          
         
        //fetch page.story
//            do {
//                try page.story.fetchIfNeeded()
//           
//            
//            vc.titleTextField.text = page.story.storyTitle
//            
//        } catch {
//            print("There was an error")
//        }
        
            //
            vc.previousContentText = page.textContent
            vc.isNewStory = isNewStory
            vc.story = page.story
            vc.homeVC = homeVC
         
 
        }
        
        
    }
    
    @IBAction func unwindToInbox(segue:UIStoryboardSegue) {
        
    }
    

}
