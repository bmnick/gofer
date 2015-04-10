# Gofer

Gofer was intended to be a multi-component service for instant ordering of coffee to be delivered to you. It is currently built as a minimum viable product against a Parse backend and Stripe as a payment processor, due to their ease of integration and support for ApplePay. 

Because of some issues with real life intruding on business ideas, it has been shelved. The app currently stands as something just short of an MVP that could be easily improved to work for other, similar ideas. All API tokens within the source have been revoked.

## Eventual components

* iOS mobile ordering app
* Android mobile ordering app
* iOS delivery app
* ?Android delivery app?
* Parse cloud code backend

## Scaling

Due to the pricing structure of Parse, if we start to acheive scale, we should look into replacing it with a custom backend service. Currently it provides CRUD endpoints for coffee orders and a Stripe communication endpoint, to create charges using the token we collect from users in the mobile apps. This should be a relatively easy item to reimplement and host on AWS or a similar cloud provider with much more reasonable price structures at scale.
