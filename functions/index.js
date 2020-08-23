const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings)
const stripe = require('stripe')('sk_test_51HHbHhIW5aSFUbq7x16hj1ERbNEmYj1vOAH5CYPGoBWfaz2nZ1HsVX4Lj0J6SvWHddVacYNMDs0jlfbKQa5IwuFd00CJK5XPZr');//TODO: ADD SECRET KEY
exports.createPaymentIntent = functions.https.onCall((data, context) => {
    return stripe.paymentIntents.create({
    amount: data.amount,
    currency: data.currency,
    payment_method_types: ['card'],

  });
});