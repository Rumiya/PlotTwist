//
//  PTActivityIndicator.swift
//  PlotTwist
//
//  Created by Lin Wei on 11/16/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation
import UIKit

class PTActivityIndicator  {
    
 
    class func show() {
        
        let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicatorView.tag = 2
        
        let indicatorImage = UIImageView()
        indicatorImage.animationImages = [UIImage]()
        
        for var index = 1; index < 13; index++ {
            let frameName = String(format: "screenAnimation%d", index)
            indicatorImage.animationImages?.append(UIImage(named: frameName)!)
        }
        
        indicatorImage.animationDuration = 1
        indicatorImage.startAnimating()
        
        indicatorImage.frame = indicatorView.bounds
        
        indicatorView.addSubview(indicatorImage)
        
        let currentWindow = UIApplication.sharedApplication().keyWindow
        
        indicatorView.center = (currentWindow?.center)!
        
        indicatorView.alpha = 1
        
        currentWindow!.addSubview(indicatorView)

        
        
    }
    
    class func dismiss() {
        
        let currentWindow = UIApplication.sharedApplication().keyWindow
        for view in (currentWindow?.subviews)! {
            if view.tag == 2 {
                let activityImageView = view.subviews.first as! UIImageView
                activityImageView.stopAnimating()
                view.removeFromSuperview()
            }
        }
        
    }
    
}