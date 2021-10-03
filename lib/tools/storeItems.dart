import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'uiFunctions.dart';

class Merchandise extends StatefulWidget {
  @override
  _MerchandiseState createState() => _MerchandiseState();
}

class _MerchandiseState extends State<Merchandise>
    with AutomaticKeepAliveClientMixin<Merchandise> {
  int productCount = 0;
  bool isLoading = false;
  List<ProductItems> productItems = [];
  List<ProductItems> productItemsStoreLive = [];
  List<ProductItems> productItemsStoreUpcoming = [];
  RefreshController _refreshController = RefreshController();
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  void _toggle() {
    _innerDrawerKey.currentState.toggle(
        // direction is optional
        // if not set, the last direction will be used
        //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.end);
  }

  @override
  void initState() {
    //getProductItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InnerDrawer(
        key: _innerDrawerKey,
        onTapClose: true, // default false
        swipe: true,
        swipeChild: true, // default true
        //colorTransitionChild: Colors.red, // default Color.black54
        colorTransitionScaffold: Colors.black54, // default Color.black54
        //When setting the vertical offset, be sure to use only top or bottom
        offset: IDOffset.only(bottom: 0.3, right: 0.98, left: 0.98, top: 0),
        scale: IDOffset.horizontal(0.5), // set the offset in both directions

        proportionalChildArea: true, // default true
        borderRadius: 80, // default 0
        leftAnimationType: InnerDrawerAnimation.quadratic, // default static
        rightAnimationType: InnerDrawerAnimation.quadratic,
        backgroundDecoration: BoxDecoration(
            color: Colors.white), // default  Theme.of(context).backgroundColor

        onDragUpdate: (double val, InnerDrawerDirection direction) {},
        innerDrawerCallback: (a) =>
            print(a), // return  true (open) or false (close)
        rightChild:
            // buildStoreItemsLiveUpcoming(
            //     isLive: false,
            //     context: context,
            //     isLoading: isLoading,
            //     varProductItems: productItemsStoreUpcoming),

            buildProductItemsStream(
                varProductItemsLive: productItemsStoreLive,
                varProductItemsUpcoming: productItemsStoreUpcoming,
                varRef: storeTimelineRef,
                context: context,
                isLoading: isLoading,
                isLive: false),

        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: Scaffold(
          body: SmartRefresher(
            child:
                // buildStoreItemsLiveUpcoming(
                //     isLive: true,
                //     context: context,
                //     isLoading: isLoading,
                //     varProductItems: productItemsStoreLive),
                buildProductItemsStream(
                    varProductItemsLive: productItemsStoreLive,
                    varProductItemsUpcoming: productItemsStoreUpcoming,
                    varRef: storeTimelineRef,
                    context: context,
                    isLoading: isLoading,
                    isLive: true),
            onRefresh: () {
              productItemsStoreUpcoming.clear();
              productItemsStoreLive.clear();
              getProductItems();
              _refreshController.refreshCompleted();
            },
            controller: _refreshController,
            header: WaterDropMaterialHeader(
              distance: 40.0,
            ),
          ),
        ));
  }

  getProductItems() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await storeTimelineRef.orderBy('timestamp', descending: true).get();
    productCount = snapshot.docs.length;
    snapshot.docs.forEach((doc) {
      if (!doc.data().containsKey("liveSaleDate") ||
          doc.data()["liveSaleDate"].toDate().isBefore(DateTime.now())) {
        productItemsStoreLive.add(ProductItems.fromDocument(doc));
      }
    });
    snapshot.docs.forEach((doc) {
      if (doc.data()["liveSaleDate"] != null &&
          doc.data()["liveSaleDate"].toDate().isAfter(DateTime.now())) {
        productItemsStoreUpcoming.add(ProductItems.fromDocument(doc));
      }
    });
    print(productItemsStoreUpcoming);
    setState(() {
      isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
