import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:kannapy/adminScreens/adminHome.dart';
import 'package:kannapy/tools/auctionItemTile.dart';
import 'package:kannapy/tools/productItems.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';
import 'package:kannapy/userScreens/profileScreens/dashBoard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class KannapyAuction extends StatefulWidget {
  final ProductItems productItems;
  KannapyAuction({this.productItems});
  @override
  _KannapyAuctionState createState() => _KannapyAuctionState();
}

class _KannapyAuctionState extends State<KannapyAuction>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  int auctionItemCount = 0;
  int auctionVaultItemCount = 0;

  RefreshController _refreshController = RefreshController();
  List<ProductItems> auctionItemsStoreLive = [];
  List<ProductItems> auctionItemsStoreUpcoming = [];
  List<ProductItems> auctionVaultItemsLive = [];
  List<ProductItems> auctionVaultItemsUpcoming = [];
  List<ProductItems> auctionItemsAll = [];

  TabController _tabBarController;

  final GlobalKey<InnerDrawerState> _innerDrawerKeyMerc =
      GlobalKey<InnerDrawerState>();

  // void _toggle() {
  //   _innerDrawerKey.currentState.toggle(
  //       // direction is optional
  //       // if not set, the last direction will be used
  //       //InnerDrawerDirection.start OR InnerDrawerDirection.end
  //       direction: InnerDrawerDirection.end);
  // }

  bool _disposed = false;
  @override
  void initState() {
    _tabBarController = TabController(length: 2, vsync: this);
    getAuctionItems();
    // getAuctionVaultItems();
    super.initState();
  }

  // getAuctionVaultItems() async {
  //   if (!_disposed) {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = true;
  //       });
  //     }
  //   }
  //   QuerySnapshot snapshot = await auctionVaultTimelineRef
  //       .orderBy('timestamp', descending: true)
  //       .get();
  //   snapshot.docs.forEach((doc) {
  //     if (!doc.data().containsKey("liveSaleDate") ||
  //         doc.data()["liveSaleDate"].toDate().isBefore(DateTime.now())) {
  //       auctionVaultItemsLive.add(ProductItems.fromDocument(doc));
  //     }
  //   });
  //   snapshot.docs.forEach((doc) {
  //     if (doc.data()["liveSaleDate"] != null &&
  //         doc.data()["liveSaleDate"].toDate().isAfter(DateTime.now())) {
  //       auctionVaultItemsUpcoming.add(ProductItems.fromDocument(doc));
  //     }
  //   });
  //
  //   if (mounted) {
  //     setState(() {
  //       isLoading = false;
  //       auctionVaultItemCount = snapshot.docs.length;
  //     });
  //   }
  // }

  getAuctionItems() async {
    if (!_disposed) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
    }
    if (mounted) {
      QuerySnapshot snapshot =
          await auctionTimelineRef.orderBy('timestamp', descending: true).get();
      snapshot.docs.forEach((doc) {
        if (!doc.data().containsKey("liveSaleDate") ||
            doc.data()["liveSaleDate"].toDate().isBefore(DateTime.now())) {
          auctionItemsStoreLive.add(ProductItems.fromDocument(doc));
        }
      });
      snapshot.docs.forEach((doc) {
        if (doc.data()["liveSaleDate"] != null &&
            doc.data()["liveSaleDate"].toDate().isAfter(DateTime.now())) {
          auctionItemsStoreUpcoming.add(ProductItems.fromDocument(doc));
        }
      });
      setState(() {
        isLoading = false;
        auctionItemCount = snapshot.docs.length;
      });
    }
    // }
  }

  Widget buildAuctionVaultPage({
    @required bool isVault,
    @required List<ProductItems> varAuctionTypeLive,
    @required List<ProductItems> varAuctionTypeUpcoming,
    @required var innerDrawerKey,
    @required varRef,
  }) {
    return InnerDrawer(
        key: innerDrawerKey,
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

        onDragUpdate: (double val, InnerDrawerDirection direction) {
          print(val);
          print(direction == InnerDrawerDirection.start);
        },
        innerDrawerCallback: (a) =>
            print(a), // return  true (open) or false (close)
        rightChild: buildAuctionLiveUpcoming(
            varAuctionItems: varAuctionTypeUpcoming,
            context: context,
            isLoading: isLoading,
            isLive: false,
            isVault: isVault), // required if leftChild is not set

        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: Scaffold(
          backgroundColor: Colors.white,
          body: SmartRefresher(
            controller: _refreshController,
            header: WaterDropMaterialHeader(
              distance: 40.0,
            ),
            onRefresh: () {
              auctionVaultItemsLive.clear();
              auctionItemsStoreLive.clear();
              auctionItemsStoreUpcoming.clear();
              auctionVaultItemsUpcoming.clear();
              getAuctionItems();
              _refreshController.refreshCompleted();
            },
            child: buildAuctionLiveUpcomingStream(
                isVault: isVault,
                isLive: true,
                context: context,
                varRef: varRef,
                varAuctionItemsLive: varAuctionTypeLive,
                varAuctionItemsUpcoming: varAuctionTypeUpcoming),
            // buildAuctionLiveUpcoming(
            //     varAuctionItems: varAuctionTypeLive,
            //     context: context,
            //     isLoading: isLoading,
            //     isLive: true,
            //     isVault: isVault),
          ),
        ));
  }

  buildAuctionItems() {
    if (isLoading) {
      return bouncingGridProgress();
    } else if (auctionVaultItemsLive.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
    List<GridTile> gridTiles = [];
    auctionItemsStoreLive.forEach((productItems) {
      gridTiles.add(GridTile(
          child: AuctionItemTile(
        productItemsAuction: productItems,
        isVault: false,
      )));
    });
    return GridView.count(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 1,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: gridTiles,
    );
  }

  buildAuctionVaultItems() {
    if (isLoading) {
      return bouncingGridProgress();
    } else if (auctionVaultItemsLive.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
    List<GridTile> gridTiles = [];
    auctionVaultItemsLive.forEach((productItems) {
      gridTiles.add(GridTile(
          child: AuctionItemTile(
        productItemsAuction: productItems,
        isVault: true,
      )));
    });
    return GridView.count(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 1,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: gridTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onLongPress: isAdmin || isMerc
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AdminHome(currentUser: currentUser, isMerc: isMerc)));
                }
              : () {},
          child: Text(
            'AUCTION HOUSE',
            style: TextStyle(
                color: Theme.of(context).appBarTheme.textTheme.headline1.color),
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.person_outline,
                  color:
                      Theme.of(context).appBarTheme.textTheme.headline1.color),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                        profileId: currentUser?.id,
                      )))),
        ],
        // bottom: TabBar(
        //     labelColor:
        //         Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        //     unselectedLabelColor: Theme.of(context).accentColor,
        //     controller: _tabBarController,
        //     indicatorColor:
        //         Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        //     tabs: [
        //       Tab(
        //         child: Text("SEED VAULT"),
        //       ),
        //       Tab(
        //         child: Text("MERCHANDISE"),
        //       ),
        //     ]),
      ),
      // body: TabBarView(controller: _tabBarController, children: [
      //   buildAuctionVaultPage(
      //       varRef: auctionVaultTimelineRef,
      //       isVault: true,
      //       varAuctionTypeLive: auctionVaultItemsLive,
      //       varAuctionTypeUpcoming: auctionVaultItemsUpcoming,
      //       innerDrawerKey: _innerDrawerKeyVault),
      //   // buildAuctionLiveUpcoming(
      //   //     context: context,
      //   //     isLive: true,
      //   //     isVault: true,
      //   //     varAuctionItems: auctionVaultItemsLive,
      //   //     isLoading: isLoading),
      //   // buildAuctionVaultItems(),
      //   // buildAuctionItems(),
      //   buildAuctionVaultPage(
      //       varRef: auctionTimelineRef,
      //       isVault: false,
      //       varAuctionTypeLive: auctionItemsStoreLive,
      //       varAuctionTypeUpcoming: auctionItemsStoreUpcoming,
      //       innerDrawerKey: _innerDrawerKeyMerc),
      // ]),

      body: buildAuctionVaultPage(
          varRef: auctionTimelineRef,
          isVault: false,
          varAuctionTypeLive: auctionItemsStoreLive,
          varAuctionTypeUpcoming: auctionItemsStoreUpcoming,
          innerDrawerKey: _innerDrawerKeyMerc),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabBarController.dispose();
    _disposed = true;
    super.dispose();
  }
}
