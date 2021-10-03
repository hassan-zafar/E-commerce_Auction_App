// import 'package:flutter/material.dart';
// import 'package:kannapy/payment/showDialogToDismiss.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// import 'package:flutter/cupertino.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
//
// class StripeExample extends StatefulWidget {
//   @override
//   _StripeExampleState createState() => _StripeExampleState();
// }
//
// class _StripeExampleState extends State<StripeExample> {
//   String text = 'Click the button to start the payment';
//   double totalCost = 10.0;
//   double tip = 1.0;
//   double tax = 0.0;
//   double taxPercent = 0.2;
//   int amount = 0;
//   bool showSpinner = false;
//   String url =
//       'https://us-central1-demostripe-b9557.cloudfunctions.net/StripePI';
//   @override
//   void initState() {
//     super.initState();
//     StripePayment.setOptions(
//       StripeOptions(
//         publishableKey:
//             'pk_test_51HEKkjIEmWkp6b7ScGJgzPctYP1DknJpw4c8ikwLRdBiDgZPHkq0GnGsNnSnqNtFlngW1oJftKzopNdMVqmUsaWb00J1DNBegr', // add you key as per Stripe dashboard      merchantId: 'merchant.thegreatestmarkeplace',
// // add you merchantId as per apple developer account
//         androidPayMode: 'test',
//       ),
//     );
//   }
//
//   void checkIfNativePayReady() async {
//     print('started to check if native pay ready');
//     bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
//     bool isNativeReady = await StripePayment.canMakeNativePayPayments(
//         ['american_express', 'visa', 'maestro', 'master_card']);
//     deviceSupportNativePay && isNativeReady
//         ? createPaymentMethodNative()
//         : createPaymentMethod();
//   }
//
//   Future<void> createPaymentMethodNative() async {
//     print('started NATIVE payment...');
//     StripePayment.setStripeAccount(null);
//     List<ApplePayItem> items = [];
//     items.add(ApplePayItem(
//       label: 'Demo Order',
//       amount: totalCost.toString(),
//     ));
//     if (tip != 0.0)
//       items.add(ApplePayItem(
//         label: 'Tip',
//         amount: tip.toString(),
//       ));
//     if (taxPercent != 0.0) {
//       tax = ((totalCost * taxPercent) * 100).ceil() / 100;
//       items.add(ApplePayItem(
//         label: 'Tax',
//         amount: tax.toString(),
//       ));
//     }
//     items.add(ApplePayItem(
//       label: 'Vendor A',
//       amount: (totalCost + tip + tax).toString(),
//     ));
//     amount = ((totalCost + tip + tax) * 100).toInt();
//     print('amount in pence/cent which will be charged = $amount');
//     //step 1: add card
//     PaymentMethod paymentMethod = PaymentMethod();
//     Token token = await StripePayment.paymentRequestWithNativePay(
//       androidPayOptions: AndroidPayPaymentRequest(
//         total_price: (totalCost + tax + tip).toStringAsFixed(2),
//         currency_code: 'GBP',
//       ),
//       applePayOptions: ApplePayPaymentOptions(
//         countryCode: 'GB',
//         currencyCode: 'GBP',
//         items: items,
//       ),
//     );
//     paymentMethod = await StripePayment.createPaymentMethod(
//       PaymentMethodRequest(
//         card: CreditCard(
//           token: token.tokenId,
//         ),
//       ),
//     );
//     paymentMethod != null
//         ? processPaymentAsDirectCharge(paymentMethod)
//         : showDialog(
//             context: context,
//             builder: (BuildContext context) => ShowDialogToDismiss(
//                 title: 'Error',
//                 content:
//                     'It is not possible to pay with this card. Please try again with a different card',
//                 buttonText: 'CLOSE'));
//   }
//
//   Future<void> createPaymentMethod() async {
//     StripePayment.setStripeAccount(null);
//     tax = ((totalCost * taxPercent) * 100).ceil() / 100;
//     amount = ((totalCost + tip + tax) * 100).toInt();
//     print('amount in pence/cent which will be charged = $amount');
//     //step 1: add card
//     PaymentMethod paymentMethod = PaymentMethod();
//     paymentMethod = await StripePayment.paymentRequestWithCardForm(
//       CardFormPaymentRequest(),
//     ).then((PaymentMethod paymentMethod) {
//       return paymentMethod;
//     }).catchError((e) {
//       print('Errore Card: ${e.toString()}');
//     });
//     paymentMethod != null
//         ? processPaymentAsDirectCharge(paymentMethod)
//         : showDialog(
//             context: context,
//             builder: (BuildContext context) => ShowDialogToDismiss(
//                 title: 'Error',
//                 content:
//                     'It is not possible to pay with this card. Please try again with a different card',
//                 buttonText: 'CLOSE'));
//   }
//
//   Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) async {
//     setState(() {
//       showSpinner = true;
//     });
//     //step 2: request to create PaymentIntent, attempt to confirm the payment & return PaymentIntent
//     final http.Response response = await http
//         .post('$url?amount=$amount&currency=GBP&paym=${paymentMethod.id}');
//     print('Now i decode');
//     if (response.body != null && response.body != 'error') {
//       final paymentIntentX = jsonDecode(response.body);
//       final status = paymentIntentX['paymentIntent']['status'];
//       final strAccount = paymentIntentX['stripeAccount'];
//       //step 3: check if payment was succesfully confirmed
//       if (status == 'succeeded') {
//         //payment was confirmed by the server without need for futher authentification
//         StripePayment.completeNativePayRequest();
//         setState(() {
//           text =
//               'Payment completed. ${paymentIntentX['paymentIntent']['amount'].toString()}p succesfully charged';
//           showSpinner = false;
//         });
//       } else {
//         //step 4: there is a need to authenticate
//         StripePayment.setStripeAccount(strAccount);
//         await StripePayment.confirmPaymentIntent(PaymentIntent(
//                 paymentMethodId: paymentIntentX['paymentIntent']
//                     ['payment_method'],
//                 clientSecret: paymentIntentX['paymentIntent']['client_secret']))
//             .then(
//           (PaymentIntentResult paymentIntentResult) async {
//             //This code will be executed if the authentication is successful
//             //step 5: request the server to confirm the payment with
//             final statusFinal = paymentIntentResult.status;
//             if (statusFinal == 'succeeded') {
//               StripePayment.completeNativePayRequest();
//               setState(() {
//                 showSpinner = false;
//               });
//             } else if (statusFinal == 'processing') {
//               StripePayment.cancelNativePayRequest();
//               setState(() {
//                 showSpinner = false;
//               });
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) => ShowDialogToDismiss(
//                       title: 'Warning',
//                       content:
//                           'The payment is still in \'processing\' state. This is unusual. Please contact us',
//                       buttonText: 'CLOSE'));
//             } else {
//               StripePayment.cancelNativePayRequest();
//               setState(() {
//                 showSpinner = false;
//               });
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) => ShowDialogToDismiss(
//                       title: 'Error',
//                       content:
//                           'There was an error to confirm the payment. Details: $statusFinal',
//                       buttonText: 'CLOSE'));
//             }
//           },
//           //If Authentication fails, a PlatformException will be raised which can be handled here
//         ).catchError((e) {
//           //case B1
//           StripePayment.cancelNativePayRequest();
//           setState(() {
//             showSpinner = false;
//           });
//           showDialog(
//               context: context,
//               builder: (BuildContext context) => ShowDialogToDismiss(
//                   title: 'Error',
//                   content:
//                       'There was an error to confirm the payment. Please try again with another card',
//                   buttonText: 'CLOSE'));
//         });
//       }
//     } else {
//       //case A
//       StripePayment.cancelNativePayRequest();
//       setState(() {
//         showSpinner = false;
//       });
//       showDialog(
//           context: context,
//           builder: (BuildContext context) => ShowDialogToDismiss(
//               title: 'Error',
//               content:
//                   'There was an error in creating the payment. Please try again with another card',
//               buttonText: 'CLOSE'));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
