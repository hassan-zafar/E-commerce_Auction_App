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
const stripe = require('stripe')('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');//TODO: ADD SECRET KEY


//const stripe = require('stripe')(functions.config().stripe.testkey)
//exports.StripePI = functions.https.onRequest(async (req, res) => {
//  stripe.paymentMethods.create(
//    {
//      payment_method: req.query.paym,
//    }, {
//      stripeAccount: stripeVendorAccount
//    },
//    function(err, clonedPaymentMethod) {
//      if (err !== null){
//        console.log('Error clone: ', err);
//        res.send('error');
//      } else {
//        console.log('clonedPaymentMethod: ', clonedPaymentMethod);
//        const fee = (req.query.amount/100) | 0;
//stripe.paymentIntents.create(
//              {
//                amount: req.query.amount,
//                currency: req.query.currency,
//                payment_method: clonedPaymentMethod.id,
//                confirmation_method: 'automatic',
//                confirm: true,
//                application_fee_amount: fee,
//                description: req.query.description,
//              }, {
//                stripeAccount: stripeVendorAccount
//              },
//              function(err, paymentIntent) {
//                // asynchronously called
//                const paymentIntentReference = paymentIntent;
//                if (err !== null){
//                  console.log('Error payment Intent: ', err);
//                  res.send('error');
//                }
//                else {
//                  console.log('Created paymentintent: ', paymentIntent);
//                  res.json({
//                    paymentIntent: paymentIntent,
//                    stripeAccount: stripeVendorAccount});
//                }
//              }
//              );
//            }
//          });
//});
exports.createPaymentIntent = functions.https.onCall((data, context) => {
    return stripe.paymentIntents.create({
    amount: data.amount,
    currency: data.currency,
    payment_method_types: ['card'],

  });
});
//For Canceling Payment
//exports.cancelPayment = functions.https.onCall(async (data, context) => {
//  try{
//  const cancel = await stripe.paymentIntents.cancel(
//    data.paymentIntentId,
//  );
//  return {
//    cancelStatus: cancel.status,
//  }
//  }catch(e){
//    console.log(e);
//    return {
//      error : e,
//      cancelStatus : ""
//    }
//  }
//});

exports.onCreateActivityFeedItem = functions
                                        .firestore
                                        .document('/activityFeed/{userId}/feedItems/{activityFeedItem}')
                                        .onCreate(async(snapshot,context)=>{
                                        console.log('Activity Feed Item Created',snapshot.data());

                                        //1) Get user Connected to the feed
                                        const userId = context.params.userId;
                                        const userRef = admin.firestore().doc(`users/${userId}`);
                                        const doc= await userRef.get();

                                        //2) Once we have user, check if they have a notification token,send notification if they have a token
                                        const androidNotificationToken = doc.data().androidNotificationToken;
                                        const createdActivityFeedItem=snapshot.data();
                                        if(androidNotificationToken){
                                        sendNotification(androidNotificationToken,createdActivityFeedItem);

                                        }
                                        else{
                                        console.log("No token for user, cannot send notification");
                                        }
                                        function sendNotification(androidNotificationToken,activityFeedItem){
                                        let body
                                        //switch body value based on notification type
                                        switch(activityFeedItem.type){
                                        case"comment":
                                        body=`${activityFeedItem.userName} replied: ${activityFeedItem.commentData}`;
                                        break;
                                        case"like":
                                        body=`${activityFeedItem.userName} liked your Post`;
                                        break;
                                        case"review":
                                        body=`${activityFeedItem.userName} reviewed ${activityFeedItem.rating},${activityFeedItem.commentData}`;
                                        break;
                                        case"mercReq":
                                        body=`${activityFeedItem.userName}   ${activityFeedItem.commentData}`;
                                        break;
                                        case"order":
                                        body=`${activityFeedItem.userName} ordered your product`;
                                        break;
                                        case"bidWin":
                                        body=`${activityFeedItem.userName} ${activityFeedItem.commentData}`;
                                        break;
                                        case"bidWinFail":
                                        body=`${activityFeedItem.userName} ${activityFeedItem.commentData}`;
                                        break;
                                        default:
                                        break;
                                        }

                                        //4)Create Message for push notification
                                        const message={
                                        notification:{body:body},
                                        token:androidNotificationToken,
                                        data:{recipient:userId,click_action:"FLUTTER_NOTIFICATION_CLICK"}
                                        };

                                         //5)Send message with admin.messaging()
                                        admin.messaging().send(message).then(response=>{
                                        //response is the message id string
                                        console.log("Successfully sent message",response);
                                        return null;
                                        }).catch(error=>{
                                        console.log("Error sending message",error)
                                        })
                                        }
                                        });
