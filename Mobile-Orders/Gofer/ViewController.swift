//
//  ViewController.swift
//  Gofer
//
//  Created by Ben Nicholas on 1/27/15.
//  Copyright (c) 2015 Ben Nicholas. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

enum Result {
    case Success(String)
    case Failure(String)
}

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, PTKViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var cardView: PTKView!
    @IBOutlet weak var coffeeButton: FlatButton!
    @IBOutlet weak var logoLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    private let client = STPAPIClient(publishableKey: "pk_test_bEG0Z8g1DGo7BxhixB9LaODF")
    private var hasReceivedLocation: Bool = false
    private var cardIsValid: Bool = false
    
    func buttonTransform() -> CGAffineTransform {
        var buttonTransform = CGAffineTransformMakeTranslation(-1000, 0)
        buttonTransform = CGAffineTransformRotate(buttonTransform, -0.4)
        
        return buttonTransform
    }
    
    func cardTransform() -> CGAffineTransform {
        var cardTransform = CGAffineTransformMakeTranslation(1000, 0)
        cardTransform = CGAffineTransformRotate(cardTransform, 0.4)
        
        return cardTransform
    }
    
    func logoTransform() -> CGAffineTransform {
        var logoTransform = CGAffineTransformMakeTranslation(0, -400)
        logoTransform = CGAffineTransformRotate(logoTransform, -0.8)
        
        return logoTransform
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            cardView?.removeFromSuperview()
            cardIsValid = true
        } else {
            cardView?.delegate = self
        }
        coffeeButton.enabled = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        coffeeButton.transform = buttonTransform()
        cardView.transform = cardTransform()
        logoLabel.transform = logoTransform()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            self.coffeeButton.transform = CGAffineTransformIdentity
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
            self.logoLabel.transform = CGAffineTransformIdentity
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
            self.cardView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Location Delegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            return
        case .Authorized, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .Denied, .Restricted:
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        hasReceivedLocation = true
        
        coffeeButton.enabled = hasReceivedLocation && cardIsValid
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
            UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseIn, animations: { () -> Void in
                self.coffeeButton.transform = self.buttonTransform()
            }, completion: { _ -> Void in
                self.performSegueWithIdentifier("requestSuccess", sender: self)
            })
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn, animations: { () -> Void in
                self.cardView.transform = self.cardTransform()
                }, completion: nil)
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
        cardIsValid = valid
        coffeeButton.enabled = hasReceivedLocation && cardIsValid
    }
    
    // MARK: - Charge and request
    
    func paymentRequestWithToken(token: STPToken!, completion: Result -> Void) {
        let manager = locationManager
        let location = locationManager.location
        let coordinate = location.coordinate
        let params = [
            "destinationAddress" : "683 Linden St.",
            "destinationGeoLat" : locationManager.location.coordinate.latitude,
            "destinationGeoLong" : locationManager.location.coordinate.longitude,
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

