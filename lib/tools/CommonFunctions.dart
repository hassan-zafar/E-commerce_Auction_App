import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

sendMail({String recipientEmail, String subject, String text, var html}) async {
  String username = 'sales@kannapy.co';
  String password = 'nomad512';
  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'Kannapy')
    ..recipients.add(recipientEmail)
    ..subject = '$subject  ${DateTime.now()}'
    ..text = text
    ..html = html;

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
  // DONE

  // Let's send another message using a slightly different syntax:
  //
  // Addresses without a name part can be set directly.
  // For instance `..recipients.add('destination@example.com')`
  // If you want to display a name part you have to create an
  // Address object: `new Address('destination@example.com', 'Display name part')`
  // Creating and adding an Address object without a name part
  // `new Address('destination@example.com')` is equivalent to
  // adding the mail address as `String`.

  // final equivalentMessage = Message()
  //   ..from = Address(username, 'Your name')
  //   ..recipients.add(Address('destination@example.com'))
  //   ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
  //   ..text = 'This is the plain text.\nThis is line 2 of the text part.'
  //   ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
  //
  // final sendReport2 = await send(equivalentMessage, smtpServer);

  // Sending multiple messages with the same connection
  //
  // Create a smtp client that will persist the connection
  var connection = PersistentConnection(smtpServer);

  // Send the first message
  // await connection.send(message);

  // send the equivalent message
  // await connection.send(equivalentMessage);

  // close the connection
  await connection.close();
}

List<BoxShadow> bxShadow = [
  BoxShadow(
      color: Colors.grey[600],
      spreadRadius: 0.5,
      blurRadius: 5,
      offset: Offset(4, 4)),
  BoxShadow(
      color: Colors.white,
      spreadRadius: 0.5,
      blurRadius: 5,
      offset: Offset(-4, -4)),
];
Widget cartItem({
  @required BuildContext context,
  @required String productName,
  @required String price,
  @required String mediaUrl,
  @required String quantity,
  @required int quantitySelected,
  @required minusQuantity,
  @required String subHeading,
  @required addQuantity,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 40.0, right: 20, top: 20, bottom: 20),
    child: Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: bxShadow,
              color: Colors.white),
          height: 100,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 80, top: 8, bottom: 0, right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                productName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                minFontSize: 12,
                overflow: TextOverflow.ellipsis,
                maxFontSize: 18,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AutoSizeText(
                    subHeading,
                    maxLines: 1,
                    minFontSize: 6,
                    maxFontSize: 12,
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
        Positioned(
          right: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.delete_outline,
              size: 20,
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: -20,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
                boxShadow: bxShadow),
            height: 90,
            width: 90,
            child: Image(
              image: CachedNetworkImageProvider(mediaUrl),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    ),
  );
}

buildProductDetails(
    {@required BuildContext context,
    @required ProductItems productItems,
    @required Widget quantityCard,
    @required Widget reviews,
    @required type,
    @required Widget buildVideoPlayer,
    @required isLive,
    @required setReminder}) {
  int idx = 0;

  Size screenSize = MediaQuery.of(context).size;
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        neumorphicTile(
          circular: false,
          padding: 2,
          anyWidget: productItems.videoUrl != null
              ? buildVideoPlayer
              : Container(
                  width: screenSize.width,
                  height: 300.0,
                  decoration: BoxDecoration(),
                  child: CarouselSlider.builder(
                    itemCount: productItems.mediaUrl.length,
                    options: CarouselOptions(
                      height: 300.0,
                      autoPlay: true,
                      enableInfiniteScroll: false,
                      initialPage: idx,
                    ),
                    itemBuilder: (context, int itemIndex) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image(
                          image: CachedNetworkImageProvider(
                              productItems.mediaUrl[itemIndex]),
                          fit: BoxFit.fill,
                        ),
                      );
                    },
                  )),
        ),
        SizedBox(
          height: 15,
        ),
        imagesListCard(context: context, productItems: productItems),
        SizedBox(
          height: 15.0,
        ),
        neumorphicTile(
          padding: 1,
          anyWidget: Container(
            width: screenSize.width * 0.8,
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  productItems.productName,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productItems.subName,
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          isAuctionMercItem
                              ? "Initial Bidding: \£${productItems.price}"
                              : "Price :£${productItems.price}",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.fade,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: productItems.ownerMediaUrl != null
                          ? CachedNetworkImageProvider(
                              productItems.ownerMediaUrl)
                          : null,
                      backgroundColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        descriptionCard(
            context: context, description: productItems.description),
        SizedBox(
          height: 15,
        ),
        isAuctionMercItem ? Container() : quantityCard,
        isAuctionMercItem
            ? Container()
            : SizedBox(
                height: 15,
              ),
        isLive ? reviews : Container(),
        SizedBox(
          height: 30,
        ),
      ],
    ),
  );
}

imagesListCard({ProductItems productItems, @required BuildContext context}) {
  return neumorphicTile(
    circular: false,
    padding: 2,
    anyWidget: Container(
      width: MediaQuery.of(context).size.width,
      height: 150.0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: productItems.mediaUrl.length,
          itemBuilder: (context, index) {
            print(index);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(new PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return Material(
                        elevation: 20,
                        color: Colors.black87,
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          height: 400.0,
                          width: 400.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Hero(
                              tag: productItems.mediaUrl[index],
                              child: CarouselSlider.builder(
                                itemCount: productItems.mediaUrl.length,
                                options: CarouselOptions(
                                    height: 400.0, initialPage: index),
                                itemBuilder: (context, int itemIndex) {
                                  return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Image(
                                        image: CachedNetworkImageProvider(
                                            productItems.mediaUrl[itemIndex]),
                                      ));
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }));
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    height: 140.0,
                    width: 100.0,
                    child: Hero(
                      tag: productItems.mediaUrl[index],
                      child: Image(
                        image: CachedNetworkImageProvider(
                            productItems.mediaUrl[index]),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    height: 140.0,
                    width: 100.0,
                    // decoration:
                    //     BoxDecoration(color: Colors.grey.withAlpha(50)),
                  ),
                ],
              ),
            );
          }),
    ),
  );
}

descriptionCard(
    {@required BuildContext context, @required String description}) {
  return neumorphicTile(
    padding: 1,
    anyWidget: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Text(
            "Description",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            description,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    ),
  );
}
