import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeedVaultItems extends StatefulWidget {
  @override
  _SeedVaultItemsState createState() => _SeedVaultItemsState();
}

class _SeedVaultItemsState extends State<SeedVaultItems>
    with AutomaticKeepAliveClientMixin<SeedVaultItems> {
  bool _disposed = false;
  bool isLoading = false;
  int productVaultCount = 0;
  List<ProductItems> productItemsVaultLive = [];
  List<ProductItems> productItemsVaultUpcoming = [];
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
    //getVaultItems();
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
        borderRadius: 50, // default 0
        leftAnimationType: InnerDrawerAnimation.quadratic, // default static
        rightAnimationType: InnerDrawerAnimation.quadratic,
        backgroundDecoration: BoxDecoration(
            color: Colors.white), // default  Theme.of(context).backgroundColor

        onDragUpdate: (double val, InnerDrawerDirection direction) {
          print(val);
          print(direction == InnerDrawerDirection.start);
        },
        innerDrawerCallback: (a) =>
            print(a), // return  true (open) or false (close)
        rightChild:
            // buildStoreItemsLiveUpcoming(
            //     isLive: false,
            //     context: context,
            //     isLoading: isLoading,
            //     varProductItems: productItemsVaultUpcoming),
            buildProductItemsStream(
                varRef: seedVaultTimelineRef,
                context: context,
                varProductItemsUpcoming: productItemsVaultUpcoming,
                varProductItemsLive: productItemsVaultLive,
                isLoading: isLoading,
                isLive: false), // required if leftChild is not set

        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: Scaffold(
          body: SmartRefresher(
            header: WaterDropMaterialHeader(
              distance: 40.0,
            ),
            controller: _refreshController,
            child:
                // buildStoreItemsLiveUpcoming (
                //     isLive: true,
                //     context: context,
                //     isLoading: isLoading,
                //     varProductItems: productItemsVaultLive),
                buildProductItemsStream(
                    varRef: seedVaultTimelineRef,
                    context: context,
                    varProductItemsUpcoming: productItemsVaultUpcoming,
                    varProductItemsLive: productItemsVaultLive,
                    isLoading: isLoading,
                    isLive: true),
            onRefresh: () {
              productItemsVaultLive.clear();
              productItemsVaultUpcoming.clear();
              getVaultItems();

              _refreshController.refreshCompleted();
            },
          ),
        ));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  getVaultItems() async {
    if (!_disposed) {
      setState(() {
        isLoading = true;
      });
    }
    QuerySnapshot snapshot =
        await seedVaultTimelineRef.orderBy('timestamp', descending: true).get();
    productVaultCount = snapshot.docs.length;
    snapshot.docs.forEach((doc) {
      if (!doc.data().containsKey("liveSaleDate") ||
          doc.data()["liveSaleDate"].toDate().isBefore(DateTime.now())) {
        productItemsVaultLive.add(ProductItems.fromDocument(doc));
      }
    });
    snapshot.docs.forEach((doc) {
      if (doc.data()["liveSaleDate"] != null &&
          doc.data()["liveSaleDate"].toDate().isAfter(DateTime.now())) {
        productItemsVaultUpcoming.add(ProductItems.fromDocument(doc));
      }
    });
    print(productItemsVaultUpcoming);
    if (!_disposed) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
