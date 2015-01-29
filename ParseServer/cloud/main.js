var Stripe = require('stripe');

Parse.Config.get().then(function(config) {
  stripe.initialize(config.get('stripe_secret_key'));
});
