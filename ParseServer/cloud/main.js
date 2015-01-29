var Stripe = require('stripe');

Parse.Config.get().then(function(config) {
  stripe.initialize(config.get('stripe_secret_key'));
});

// States for individual requests:
var unpaidState = 0,
    readyState = 1,
    fulfilledState = 2,
    cancelledState = 3,
    errorState = 4;

/*
 * Create a CoffeeRequest, authorize payment through stripe, and push the request
 * into a fulfillable state.
 */
 Parse.Cloud.define('requestCoffee', function(request, response) {
   Parse.Cloud.useMasterKey();

   var coffeeRequest;

   Parse.Promise.as().then(function() {
     // Create a new coffee request with the given information
     var newRequest = new Parse.Object('CoffeeRequest');
     newRequest.set('destinationAddress', request.params.destinationAddress);
     newRequest.set('destinationGeo', request.params.destinationGeo);
     newRequest.set('state', unpaidState);

     return newRequest.save();

   }).then(function(result) {
     // Authorize the payment to stripe

   }).then(function(result) {
     // Move the request to a fulfillable state

   }, function(error) {
     // This is a global error handler
     if (coffeeRequest) {
       coffeeRequest.set('state', errorState);

       coffeeRequest.save().then(function() {
         response.error(error);
       });
     }
   });
 });
