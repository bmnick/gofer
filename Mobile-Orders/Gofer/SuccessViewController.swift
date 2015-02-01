//
//  SuccessViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/31/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var moreButton: FlatButton!
    
    func leftTransform() -> CGAffineTransform {
        var leftTransform = CGAffineTransformMakeTranslation(-1000, 0)
        leftTransform = CGAffineTransformRotate(leftTransform, 0.4)
        
        return leftTransform
    }
    
    func rightTransform() -> CGAffineTransform {
        var rightTransform = CGAffineTransformMakeTranslation(1000, 0)
        rightTransform = CGAffineTransformRotate(rightTransform, -0.4)
        
        return rightTransform
    }
    
    func bottomTransform() -> CGAffineTransform {
        var bottomTransform = CGAffineTransformMakeTranslation(0, 400)
        bottomTransform = CGAffineTransformRotate(bottomTransform, 0.4)
        
        return bottomTransform
    }
    
    override func viewWillAppear(animated: Bool) {
        successLabel.transform = leftTransform()
        actionLabel.transform = rightTransform()
        
        moreButton.transform = bottomTransform()
    }
    
    override func viewDidAppear(animated: Bool) {
        successLabel.hidden = false
        actionLabel.hidden = false
        moreButton.hidden = false
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.actionLabel.transform = CGAffineTransformIdentity
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
            self.moreButton.transform = CGAffineTransformIdentity
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
            self.successLabel.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
