//
//  ViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/27/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func getCoffee(sender: UIButton) {
        let paymentRequest = Stripe.paymentRequestWithMerchantIdentifier("merchant.coffee.gofer")
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Coffee Delivery", amount: NSDecimalNumber(string: "5.00"))]
        
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            let paymentController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentController.delegate = self
            
            presentViewController(paymentController, animated: true, completion: nil)
        } else {
            // ApplePay not supported... PaymentKit to the resue?
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        var testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        let client = STPAPIClient(publishableKey: "pk_test_bEG0Z8g1DGo7BxhixB9LaODF")
        
        client.createTokenWithPayment(payment) { (token: STPToken!, optionalError: NSError!) -> Void in
            if let error = optionalError {
                completion(.Failure)
                return
            } else {
                NSLog("Would be charging on the server now...")
                completion(.Success)
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

