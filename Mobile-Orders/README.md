# Gofer Mobile Orders app

This is the mobile ordering app component for Gofer, that will run on users' devices and inform us when and where they want their deliveries. 

## Development instructions

We're using cocoapods in here, but the pods are frozen locally so you don't need the tools to get started. It should be as simple as clone, open the workspace, and build. 

Signing config is currently against @bmnick 's personal account. Until we have a corporation set up and a new iTunes connect account in place, signing is going to be agailnst potentially the wrong destination - we can publish but it will be under Ben's name.

This is set up to allow payment processing on both ApplePay eligible devices and older devices, using Stripe's provided PaymentKit, which gives a very nice little credit card input. 

## Major integration components that should be happening:

* Fastlane for deploys
* Travis:ci for CI if it's going to continue
* Public bug tracker on Github for clients to file issues

