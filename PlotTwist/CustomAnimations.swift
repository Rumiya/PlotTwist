//
//  CustomAnimations.swift
//  PlotTwist
//
//  Created by Rumiya Murtazina on 11/12/15.
//  Copyright © 2015 abearablecode. All rights reserved.
//

import Foundation

func pushViewControllerRightToLeft(fromVC:UIViewController, toDVC:UIViewController){

    let fromView:UIView = fromVC.view
    let toView:UIView = toDVC.view
    let viewSize = fromView.frame

    fromView.superview?.addSubview(toView)
    toView.frame = CGRectMake(viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height)

    UIView .animateWithDuration(1, animations: ({
        fromView.frame = CGRectMake( -viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height);
        toView.frame = CGRectMake(0, viewSize.origin.y, viewSize.width, viewSize.size.height)
    }), completion: { finished in
        fromView.removeFromSuperview()
        UIApplication.sharedApplication().keyWindow!.rootViewController = toDVC;
        fromVC.presentViewController(toDVC, animated: false, completion: nil)

    })
}

func pushViewControllerLeftToRight(fromVC:UIViewController, toDVC:UIViewController){

    let fromView:UIView = fromVC.view
    let toView:UIView = toDVC.view
    let viewSize = fromView.frame

    fromView.superview?.addSubview(toView)
    toView.frame = CGRectMake(viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height)

    UIView .animateWithDuration(1, animations: ({
        fromView.frame = CGRectMake( -viewSize.width, viewSize.origin.y, viewSize.width, viewSize.size.height);
        toView.frame = CGRectMake(0, viewSize.origin.y, viewSize.width, viewSize.size.height)
    }), completion: { finished in
        fromView.removeFromSuperview()
        UIApplication.sharedApplication().keyWindow!.rootViewController = toDVC;
        fromVC.presentViewController(toDVC, animated: false, completion: nil)

    })

}