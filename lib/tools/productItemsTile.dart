import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'file:///C:/kannapy/lib/userScreens/productScreen.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/userScreens/home.dart';

class ProductItemsTile extends StatefulWidget {
  final ProductItems productItems;
  ProductItemsTile(this.productItems);
  bool favouritePressed = false;
  @override
  _ProductItemsTileState createState() => _ProductItemsTileState();
}

class _ProductItemsTileState extends State<ProductItemsTile> {
  bool favouritePressed = false;
  showProduct(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductScreen(
                  productId: widget.productItems.productId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAuctionItem = false;
        });
        showProduct(context);
      },
      child: Card(
        child: Stack(
          alignment: FractionalOffset.topLeft,
          children: <Widget>[
            Stack(
              alignment: FractionalOffset.bottomCenter,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          widget.productItems.mediaUrl[0]),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.productItems.productName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          widget.productItems.price,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.black38,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.black38,
                  ),
                  width: 60.0,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      Text(
                        widget.productItems.rating,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.black38,
                  ),
                  width: 50.0,
                  child: IconButton(
                    icon: favouritePressed
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      favouritePressed
                          ? favouritePressed = false
                          : favouritePressed = true;
                      setState(() {
                        this.favouritePressed = favouritePressed;
                        if (favouritePressed = false) {
                          favouritesRef
                              .document(currentUser.id)
                              .collection("favouriteProducts")
                              .document(widget.productItems.productId)
                              .delete();
                          BotToast.showText(text: "Deleted To Favourites");
                        } else {
                          favouritesRef
                              .document(currentUser.id)
                              .collection("favouriteProducts")
                              .document(widget.productItems.productId)
                              .setData({
                            "mediaUrl": widget.productItems.mediaUrl[0],
                            "productId": widget.productItems.productId,
                            "userId": currentUser.id,
                            "productName": widget.productItems.productName,
                            "productPrice": widget.productItems.price,
                            "quantityLeft": widget.productItems.quantity,
                          });
                          BotToast.showText(text: "Added To Favourites");
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
