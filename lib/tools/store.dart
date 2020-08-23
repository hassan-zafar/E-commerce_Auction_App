class Store {
  String itemName;
  double itemPrice;
  String itemImage;
  double itemRating;

  Store.items({this.itemName, this.itemPrice, this.itemImage, this.itemRating});
}

List<Store> storeItems = [
  Store.items(
    itemName: 'dsfss',
    itemPrice: 343.0,
    itemRating: 3.0,
    itemImage: "https://bit.ly/3a704aM",
  ),
  Store.items(
    itemName: 'asere',
    itemPrice: 33.0,
    itemRating: 2.0,
    itemImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQW7j8Cxlx8sGaS48NdbyAuNZlclKwGLSA6Vg&usqp=CAU",
  ),
  Store.items(
    itemName: 'xcv',
    itemPrice: 43.0,
    itemRating: 0.0,
    itemImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTZ2tNCOGwmYGy5MpK-HWDcWSq0eyPLazyUTA&usqp=CAU",
  ),
  Store.items(
    itemName: 'jhjk',
    itemPrice: 34.0,
    itemRating: 1.0,
    itemImage: "https://bit.ly/3fNTXK1",
  ),
  Store.items(
    itemName: 'asere',
    itemPrice: 33.0,
    itemRating: 2.0,
    itemImage: "https://bit.ly/2XIIViS",
  ),
];
