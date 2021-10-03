import 'package:animations/animations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/productScreens/productScreen.dart';
import 'package:auto_size_text/auto_size_text.dart';

class VaultItemTile extends StatefulWidget {
  final ProductItems productItems;
  VaultItemTile({this.productItems});
  @override
  _VaultItemTileState createState() => _VaultItemTileState();
}

class _VaultItemTileState extends State<VaultItemTile> {
  bool isFavourite = false;
  bool isInCart = false;
  showProduct(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductScreen(
                  hasAllData: true,
                  productItems: widget.productItems,
                  productId: widget.productItems.productId,
                )));
  }

  handleFavourite() async {
    bool _isFavourite = widget.productItems.favourites[currentUser.id] == true;
    if (_isFavourite) {
      BotToast.showText(text: "Removed From Wish List");
      favouritesRef
          .doc(currentUser.id)
          .collection("favouriteProducts")
          .doc(widget.productItems.productId)
          .delete();
      seedVaultTimelineRef
          .doc(widget.productItems.productId)
          .update({"favourites.${currentUser.id}": false});
      setState(() {
        widget.productItems.favourites[currentUser.id] = false;
        isFavourite = false;
      });
    } else if (!isFavourite) {
      BotToast.showText(text: "Added To Wish List");
      favouritesRef
          .doc(currentUser.id)
          .collection("favouriteProducts")
          .doc(widget.productItems.productId)
          .set({
        "mediaUrl": widget.productItems.mediaUrl[0],
        "productId": widget.productItems.productId,
        "userId": currentUser.id,
        "productName": widget.productItems.productName,
        "productPrice": widget.productItems.price,
        "quantityLeft": widget.productItems.quantity,
        'type': widget.productItems.type,
        "productItems": widget.productItems
      });
      seedVaultTimelineRef
          .doc(widget.productItems.productId)
          .update({"favourites.${currentUser.id}": true});
      setState(() {
        isFavourite = true;
        widget.productItems.favourites[currentUser.id] = true;
      });
    }
  }

  handleCart() async {
    bool _isInCart = widget.productItems.carts[currentUser.id] == true;
    print(_isInCart);
    if (_isInCart) {
      BotToast.showText(text: "Removed From Cart");
      cartRef
          .doc(currentUser.id)
          .collection("cartItems")
          .doc(widget.productItems.productId)
          .delete();
      seedVaultTimelineRef
          .doc(widget.productItems.productId)
          .update({"carts.${currentUser.id}": false});
      setState(() {
        widget.productItems.carts[currentUser.id] = false;
        isInCart = false;
      });
    } else if (!_isInCart) {
      BotToast.showText(text: "Added To Carts");
      await cartRef
          .doc(currentUser.id)
          .collection("cartItems")
          .doc(widget.productItems.productId)
          .set({
        "mediaUrl": widget.productItems.mediaUrl[0],
        "productId": widget.productItems.productId,
        "userId": currentUser.id,
        "productName": widget.productItems.productName,
        "productPrice": widget.productItems.price,
        'productSubHeading': widget.productItems.subName,
        "quantityLeft": widget.productItems.quantity,
        'quantitySelected': 1,
        "type": widget.productItems.type,
        "bonus": widget.productItems.bonus,
      });
      await seedVaultTimelineRef
          .doc(widget.productItems.productId)
          .update({"carts.${currentUser.id}": true});
      setState(() {
        isInCart = true;
        widget.productItems.carts[currentUser.id] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("is in vault item");
    isInCart = widget.productItems.carts[currentUser.id] == true;
    isFavourite = widget.productItems.favourites[currentUser.id] == true;
    return Padding(
      padding: EdgeInsets.all(8),
      child: neumorphicTile(
        padding: 0,
        circular: false,
        anyWidget: OpenContainer(
          closedBuilder: (context, actions) {
            print('vault item opened');
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stack(
                //   alignment: FractionalOffset.topLeft,
                //    children: <Widget>[
                Container(
                  height: 135,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          widget.productItems.mediaUrl[0]),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                //   ],
                //  ),
                Container(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          widget.productItems.productName,
                          maxLines: 1,
                          minFontSize: 6,
                          maxFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        AutoSizeText(
                          widget.productItems.subName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          minFontSize: 6,
                          maxFontSize: 12,
                          style: TextStyle(color: Colors.black54, fontSize: 10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                widget.productItems.sex != null
                                    ? AutoSizeText(
                                        widget.productItems.sex,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        minFontSize: 6,
                                        maxFontSize: 12,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10),
                                      )
                                    : Container(),
                                AutoSizeText(
                                  "£${widget.productItems.price}",
                                  maxLines: 1,
                                  minFontSize: 6,
                                  maxFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 12,
                              backgroundImage:
                                  widget.productItems.ownerMediaUrl != null
                                      ? CachedNetworkImageProvider(
                                          widget.productItems.ownerMediaUrl)
                                      : null,
                              backgroundColor: Colors.white,
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: handleCart,
                              child: Container(
                                height: 30.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.black38,
                                ),
                                width: 40,
                                child: Icon(
                                  isInCart
                                      ? Icons.shopping_cart
                                      : Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              height: 30.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.black38,
                              ),
                              width: 40.0,
                              child: IconButton(
                                icon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: handleFavourite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          closedElevation: 0,
          openBuilder: (context, actions) {
            isAuctionMercItem = false;
            isStoreItem = false;
            isVaultItem = true;
            return ProductScreen(
              hasAllData: true,
              productItems: widget.productItems,
              productId: widget.productItems.productId,
            );
          },
        ),
      ),
    );
    //   GestureDetector(
    //   onTap: () {
    //     setState(() {
    //       isAuctionMercItem = false;
    //       isStoreItem = false;
    //       isVaultItem = true;
    //     });
    //     showProduct(context);
    //   },
    //   child: ,
    // );
  }
}
