var Stripe = require('stripe');

// States for individual requests:
var unpaidState = 0,
    readyState = 1,
    fulfilledState = 2,
    cancelledState = 3,
    errorState = 4;

/*
 * Because we need to initialize stripe from config variables, we need to
 * configure it in a parse context. We also need to only configure it once,
 * so this flag will ensure that.
 */
var initialized = false;

/*
 * Create a CoffeeRequest, authorize payment through stripe, and push the request
 * into a fulfillable state.
 *
 * Params:
 *  destinationAddress: The address we need to deliver to.
 *  destionationGeoLat: The latitude of the geographic coordinates of the delivery.
 *  destionationGeoLong: The longitude of the geographic coordinates of the delivery.
 *  token: The stripe token gathered from the user to charge.
 */
 Parse.Cloud.define('requestCoffee', function(request, response) {
   if (!initialized) {
     Parse.Config.get().then(function(config) {
       Stripe.initialize(config.get('stripe_secret_key'));
       initialized = true;
     });
   }

   Parse.Cloud.useMasterKey();

   var coffeeRequest;

   Parse.Promise.as().then(function() {
     // Create a new coffee request with the given information
     coffeeRequest = new Parse.Object('CoffeeRequest');
     coffeeRequest.set('destinationAddress', request.params.destinationAddress);
     coffeeRequest.set('state', unpaidState);
     coffeeRequest.set('destinationGeo', new Parse.GeoPoint({
       latitude: request.params.destinationGeoLat,
       longitude: request.params.destinationGeoLong
     }));

     return coffeeRequest.save().then(null, function(error) {
       return Parse.Promise.error("Couldn't request the coffee. Your credit card was not charged.");
     });

   }).then(function(result) {
     // Charge their card through Stripe
     return Stripe.Charges.create({
       amount: 500,
       currency: 'usd',
       card: request.params.token
     }).then(null, function(error) {
       return Parse.Promise.error("Couldn't charge your card. Your credit card was not charged.");
     });
   }).then(function(result) {
     // Move the request to a fulfillable state
     coffeeRequest.set('state', readyState);

     return coffeeRequest.save().then(null, function(error) {
       return Parse.Promise.error("A critical error occurred. Please contact us and we'll make it right.");
     });
   }).then(function() {
     response.success('On the way!');
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
