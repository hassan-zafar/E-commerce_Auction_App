import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/productScreens/productScreen.dart';
import 'package:kannapy/tools/CommonFunctions.dart';
import 'package:kannapy/models/mailTemplate.dart';

class ProductItemsTile extends StatefulWidget {
  final ProductItems productItems;
  final bool isLive;
  final varRef;
  ProductItemsTile(
      {this.productItems, @required this.isLive, @required this.varRef});
  @override
  _ProductItemsTileState createState() => _ProductItemsTileState();
}

class _ProductItemsTileState extends State<ProductItemsTile> {
  bool isFavourite = false;
  bool isInCart = false;
  handleFavourite() async {
    bool _isFavourite = widget.productItems.favourites[currentUser.id] == true;
    if (_isFavourite) {
      BotToast.showText(text: "Removed From Wish list");
      favouritesRef
          .doc(currentUser.id)
          .collection("favouriteProducts")
          .doc(widget.productItems.productId)
          .delete();
      widget.varRef
          .doc(widget.productItems.productId)
          .update({"favourites.${currentUser.id}": false});
      if (mounted) {
        setState(() {
          widget.productItems.favourites[currentUser.id] = false;
          isFavourite = false;
        });
      }
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
        "type": widget.productItems.type,
        "productItems": widget.productItems,
      });
      widget.varRef
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
    if (_isInCart) {
      BotToast.showText(text: "Removed From Cart");
      cartRef
          .doc(currentUser.id)
          .collection("cartItems")
          .doc(widget.productItems.productId)
          .delete();
      widget.varRef
          .doc(widget.productItems.productId)
          .update({"carts.${currentUser.id}": false});
      setState(() {
        widget.productItems.carts[currentUser.id] = false;
        isInCart = false;
      });
    } else if (!_isInCart) {
      BotToast.showText(text: "Added To Carts");
      setState(() {
        isInCart = true;
        widget.productItems.carts[currentUser.id] = true;
      });
      print(widget.productItems.productId);
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
      await widget.varRef
          .doc(widget.productItems.productId)
          .update({"carts.${currentUser.id}": true});
    }
  }

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

  @override
  Widget build(BuildContext context) {
    isInCart = widget.productItems.carts[currentUser.id] == true;
    isFavourite = widget.productItems.favourites[currentUser.id] == true;
    return Padding(
      padding: EdgeInsets.all(8),
      child: neumorphicTile(
        padding: 0,
        circular: false,
        anyWidget: OpenContainer(
          closedBuilder: (context, actions) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    //height: 133,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            widget.productItems.mediaUrl[0]),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          widget.productItems.productName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              //   fontSize: 16
                              ),
                          maxLines: 1,
                          minFontSize: 18,
                          maxFontSize: 24,
                        ),
                        AutoSizeText(
                          widget.productItems.subName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          minFontSize: 16,
                          maxFontSize: 22,
                          style: TextStyle(
                            color: Colors.black54,
                            // fontSize: 16
                          ),
                        ),
                        widget.productItems.sex != null
                            ? AutoSizeText(
                                widget.productItems.sex,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                minFontSize: 16,
                                maxFontSize: 22,
                                style: TextStyle(
                                  color: Colors.black54,
                                  // fontSize: 16
                                ),
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AutoSizeText(
                              "£${widget.productItems.price}",
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              minFontSize: 18,
                              maxFontSize: 30,
                              softWrap: true,
                              style: TextStyle(
                                color: Colors.red,
                                //fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: handleCart,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(
                                      isInCart
                                          ? Icons.shopping_cart
                                          : Icons.add_shopping_cart,
                                      //color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: handleFavourite,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(
                                      isFavourite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 25,
                                      //color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            CachedNetworkImage(
                              imageUrl: widget.productItems.ownerMediaUrl,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 18,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          openBuilder: (context, actions) {
            isAuctionMercItem = false;
            isVaultItem = false;
            isStoreItem = true;
            return ProductScreen(
              hasAllData: true,
              productItems: widget.productItems,
              productId: widget.productItems.productId,
            );
          },
          closedElevation: 0,
        ),
      ),
    );
  }
}
