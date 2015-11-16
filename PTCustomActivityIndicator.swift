////
////  PTCustomActivityIndicator.swift
////  PlotTwist
////
////  Created by Lin Wei on 11/16/15.
////  Copyright © 2015 abearablecode. All rights reserved.
////
//
//import UIKit
//
//class PTCustomActivityIndicator: UIView {
//
//    class func show() {
//        
//        let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        
//        let indicatorImage = UIImageView()
//        indicatorImage.animationImages = [UIImage]()
//        
//        for var index = 1; index < 13; index++ {
//            let frameName = String(format: "screenAnimation%05d", index)
//            indicatorImage.animationImages?.append(UIImage(named: frameName)!)
//        }
//        
//        indicatorImage.animationDuration = 1
//        indicatorImage.startAnimating()
//        
//        indicatorView.addSubview(indicatorImage)
//        
//        let currentWindow = UIApplication.sharedApplication().keyWindow
//        
//        indicatorView.center = (currentWindow?.center)!
//        
//        currentWindow!.addSubview(indicatorView)
//        
//        
//        
//    }
//    
//    class func dismiss() {
//        
//        let currentWindow = UIApplication.sharedApplication().keyWindow
//        currentWindow!.
//        
//        
//    }
//
//
//}
