//
//  PaymentViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/27/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, PTKViewDelegate {

    @IBOutlet var paymentView: PTKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentView!.delegate = self
        view.addSubview(paymentView!)
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        self.navigationItem.rightBarButtonItem?.enabled = valid
    }
    
    @IBAction func submitOrder(sender: AnyObject) {
        (presentingViewController as ViewController).manualPaymentController(self, withCard: paymentView!.card)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
