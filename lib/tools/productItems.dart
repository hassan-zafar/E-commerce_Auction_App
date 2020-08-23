import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

int quantitySelected = 1;
var varRef;

class ProductItems extends StatefulWidget {
  final String productId;
  final String ownerId;
  final String userName;
  final List<dynamic> mediaUrl;
  final String productName;
  final String description;
  final String subName;
  dynamic bids;
  dynamic price;
  dynamic quantity;
  dynamic rating;
  dynamic favourites;
  dynamic carts;
  String deliveryTime;
  String type;
  ProductItems(
      {this.deliveryTime,
      this.productId,
      this.ownerId,
      this.userName,
      this.mediaUrl,
      this.productName,
      this.description,
      this.subName,
      this.price,
      this.quantity,
      this.rating,
      this.favourites,
      this.carts,
      this.type,
      this.bids});
  factory ProductItems.fromDocument(DocumentSnapshot doc) {
    return ProductItems(
      productId: doc["productId"],
      ownerId: doc["ownerId"],
      userName: doc["userName"],
      description: doc["description"],
      productName: doc["productName"],
      mediaUrl: doc["mediaUrl"],
      carts: doc['carts'],
      favourites: doc["favourites"],
      price: doc['price'],
      quantity: doc["quantity"],
      rating: doc['rating'],
      subName: doc["subName"],
      deliveryTime: doc['deliveryTime'],
      type: doc['type'],
      bids: doc['bids'],
    );
  }
  @override
  _ProductItemsState createState() => _ProductItemsState(
        productId: this.productId,
        ownerId: this.ownerId,
        userName: this.userName,
        description: this.description,
        productName: this.productName,
        mediaUrl: this.mediaUrl,
        carts: this.carts,
        favourites: this.favourites,
        price: this.price,
        quantity: this.quantity,
        rating: this.rating,
        subName: this.subName,
        deliveryTime: this.deliveryTime,
        type: this.type,
        bids: this.bids,
      );
}

class _ProductItemsState extends State<ProductItems> {
  final String currentUserId = currentUser?.id;
  final String productId;
  final String ownerId;
  final String userName;
  final dynamic mediaUrl;
  final String productName;
  final String description;
  final String subName;
  final String deliveryTime;
  final String type;
  dynamic bids;
  dynamic price;
  dynamic quantity;
  dynamic rating;
  final String timestamp;
  dynamic favourites;
  dynamic carts;
  _ProductItemsState({
    this.productId,
    this.ownerId,
    this.userName,
    this.description,
    this.productName,
    this.mediaUrl,
    this.carts,
    this.favourites,
    this.price,
    this.quantity,
    this.rating,
    this.subName,
    this.type,
    this.deliveryTime,
    this.timestamp,
    this.bids,
  });
  buildProductDetails() {
    int idx = 0;
    if (isAuctionItem) {
      setState(() {
        varRef = auctionTimelineRef;
      });
    } else {
      setState(() {
        varRef = storeTimelineRef;
      });
    }
    return FutureBuilder(
        future: varRef.document(productId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return bouncingGridProgress();
          }

          ProductItems productItems = ProductItems.fromDocument(snapshot.data);
          Size screenSize = MediaQuery.of(context).size;
          return Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    height: 300.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(120),
                        bottomRight: Radius.circular(120),
                      ),
                    ),
                    child: Image(
                      image: CachedNetworkImageProvider(
                          productItems.mediaUrl[idx]),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Container(
                    height: 300.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(120),
                        bottomRight: Radius.circular(120),
                      ),
                      color: Colors.grey.withAlpha(45),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50.0,
              ),
              Card(
                color: Colors.black12,
                child: Container(
                  width: screenSize.width,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        productName,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        subName,
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        deliveryTime,
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SmoothStarRating(
                                color: Colors.amber,
                                allowHalfRating: true,
                                size: 20.0,
                                isReadOnly: true,
                                rating: double.parse(rating),
                                defaultIconData: Icons.star_border,
                                filledIconData: Icons.star,
                                halfFilledIconData: Icons.star_half,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                rating,
                              )
                            ],
                          ),
                          Text(
                            isAuctionItem
                                ? "Initial Bidding: \$$price"
                                : "Price :\$$price",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
              imagesListCard(productItems),
              descriptionCard(),
              isAuctionItem ? Text("") : quantityCard(),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: buildProductDetails());
  }

  descriptionCard() {
    return Card(
      color: Colors.black12,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Description",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              description,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  imagesListCard(ProductItems productItems) {
    return Card(
      color: Colors.black12,
      child: Container(
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
                          color: Colors.black38,
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            height: 400.0,
                            width: 400.0,
                            child: InkWell(
                                child: Hero(
                                    tag: productItems.mediaUrl[index],
                                    child: Image.network(
                                        productItems.mediaUrl[index]))),
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
                        child: Image.network(
                          productItems.mediaUrl[index],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      height: 140.0,
                      width: 100.0,
                      decoration:
                          BoxDecoration(color: Colors.grey.withAlpha(50)),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget quantityCard() {
    return Card(
      color: Colors.black12,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              quantity,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: CircleAvatar(
                    child: Icon(Icons.remove),
                  ),
                  onTap: () {
                    setState(() {
                      if (quantitySelected > 2) {
                        quantitySelected = quantitySelected - 1;
                      }
                    });
                  },
                ),
                Text("$quantitySelected"),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (quantitySelected < int.parse(quantity)) {
                        quantitySelected = quantitySelected + 1;
                      }
                    });
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
