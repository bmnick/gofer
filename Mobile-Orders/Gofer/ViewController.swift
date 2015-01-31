//
//  ViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/27/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, PTKViewDelegate {
    
    @IBOutlet var cardView: PTKView?
    @IBOutlet weak var coffeeButton: FlatButton!
    
    private let client = STPAPIClient(publishableKey: "pk_test_bEG0Z8g1DGo7BxhixB9LaODF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            cardView?.removeFromSuperview()
        } else {
            cardView?.delegate = self
        }
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
            manualPaymentAuthorization(cardView!.card)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        
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
    
    func manualPaymentAuthorization(paymentCard: PTKCard) {
        let card = STPCard()
        card.number = paymentCard.number
        card.expMonth = paymentCard.expMonth
        card.expYear = paymentCard.expYear
        card.cvc = paymentCard.cvc
        
        client.createTokenWithCard(card) { (token: STPToken!, optionalError: NSError?) -> Void in
            if let error = optionalError {
                let alertController = UIAlertController(title: "Invalid card", message: "try again", preferredStyle: .Alert)
                
                let OKAction = UIAlertAction(title: "Try again", style: .Default) { (action) in
                    return
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                NSLog("Would be charging on the server now...")
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        coffeeButton.enabled = valid
    }
}

