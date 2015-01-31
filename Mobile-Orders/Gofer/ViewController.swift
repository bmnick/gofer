//
//  ViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/27/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit
import Parse

enum Result {
    case Success(String)
    case Failure(String)
}

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
            coffeeButton.enabled = false
        }
        // Do any additional setup after loading the view, typically from a nib.
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
    
    // MARK: - Apple Pay interaction
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        
        client.createTokenWithPayment(payment) { (token: STPToken!, optionalError: NSError!) -> Void in
            if let error = optionalError {
                completion(.Failure)
                return
            } else {
                self.paymentRequestWithToken(token) { (result) -> Void in
                    switch result {
                    case .Success:
                        completion(.Success)
                    case .Failure:
                        completion(.Failure)
                    }
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("requestSuccess", sender: self)
        })
    }
    
    // MARK: - PaymentKit interaction
    
    func manualPaymentAuthorization(paymentCard: PTKCard) {
        coffeeButton.enabled = false
        
        let card = STPCard()
        card.number = paymentCard.number
        card.expMonth = paymentCard.expMonth
        card.expYear = paymentCard.expYear
        card.cvc = paymentCard.cvc
        
        client.createTokenWithCard(card) { (token: STPToken!, optionalError: NSError?) -> Void in
            if let error = optionalError {
                self.alert("Invalid card", body: "Card could not be charged", button: "Try again")
            } else {
                self.paymentRequestWithToken(token) {(result) -> Void in
                    switch result {
                    case .Success(let response):
                        self.alert("Charged", body: response, button: "OK")
                    case .Failure(let problem):
                        self.alert("Invalid card", body: problem, button: "Try again")
                    }
                }
            }
        }
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        coffeeButton.enabled = valid
    }
    
    // MARK: - Charge and request
    
    func paymentRequestWithToken(token: STPToken!, completion: Result -> Void) {
        let params = [
            "destinationAddress" : "683 Linden St.",
            "destinationGeoLat" : 43.136810,
            "destinationGeoLong" : -77.595786,
            "token" : token.tokenId
        ]
        PFCloud.callFunctionInBackground("requestCoffee", withParameters: params) { (ret, err) -> Void in
            if let error = err {
                completion(.Failure(error.userInfo!["error"] as String))
            } else {
                completion(.Success("success"))
            }
        }
    }
    
    // MARK: - Helpers
    
    func alert(title: String, body: String, button: String) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: button, style: .Default) { (action) in
            self.performSegueWithIdentifier("requestSuccess", sender: self)
            
            return
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IB Actions
    
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
    
    @IBAction func orderAgain(unwindSegue: UIStoryboardSegue) {
        coffeeButton.enabled = true
    }
    
}

