// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
//
// Widget appTextField({
//   IconData textIcon,
//   String textHint,
//   String labelText,
//   Color iconColor,
//   textValidator,
//   onSavedFunc,
//   Function obsPassText,
//   TextEditingController controller,
//   bool obscureText = false,
// }) {
//   return Padding(
//     padding: const EdgeInsets.only(left: 18.0, right: 18.0),
//     child: TextFormField(
//       onSaved: onSavedFunc,
//       validator: textValidator,
//       style: TextStyle(color: Colors.white),
//       controller: controller,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(5.0)),
//         ),
//         labelText: labelText,
//         hintText: textHint == null ? textHint = "" : textHint,
//         icon: textIcon == null
//             ? Container()
//             : Icon(
//                 textIcon,
//                 color: iconColor,
//               ),
//       ),
//     ),
//   );
// }
//
// Widget appButton({
//   String buttonText,
//   Color btnColor,
//   VoidCallback onBtnClicked,
// }) {
//   return RaisedButton(
//     onPressed: onBtnClicked,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(5.0)),
//     ),
//     color: btnColor,
//     padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 10.0),
//     child: Text(buttonText,
//         style: TextStyle(
//           fontSize: 20.0,
//           color: Colors.white,
//         )),
//   );
// }
//
// Widget productTextField(
//     {String textTitle,
//     String textHint,
//     double height,
//     TextEditingController controller,
//     TextInputType textType}) {
//   // ignore: unnecessary_statements
//   textTitle == null ? textTitle = "Enter Title" : textTitle;
//   // ignore: unnecessary_statements
//   textHint == null ? textHint = "Enter Hint" : textHint;
//   // ignore: unnecessary_statements
//   height == null ? height = 50.0 : height;
//   //height !=null
//
//   return Column(
//     //mainAxisAlignment: MainAxisAlignment.start,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: <Widget>[
//       new Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: new Text(
//           textTitle,
//           style:
//               new TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//         ),
//       ),
//       new Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//         child: new Container(
//           height: height,
//           decoration: new BoxDecoration(
//               color: Colors.white,
//               border: new Border.all(color: Colors.white),
//               borderRadius: new BorderRadius.all(new Radius.circular(4.0))),
//           child: new Padding(
//             padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//             child: new TextField(
//               controller: controller,
//               keyboardType: textType == null ? TextInputType.text : textType,
//               decoration: new InputDecoration(
//                   border: InputBorder.none, hintText: textHint),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// void showSnackBar({
//   String message,
//   final scaffoldKey,
//   bool loginSuccess,
// }) {
//   scaffoldKey.currentState.showSnackBar(SnackBar(
//       backgroundColor: loginSuccess == false ? Colors.red : Colors.black,
//       duration: Duration(seconds: 3),
//       content: Text(
//         message,
//         style: TextStyle(color: Colors.white),
//       )));
// }
//
// //displayProgressDialog(BuildContext context) {
// //  Navigator.of(context).push(new PageRouteBuilder(
// //      opaque: false,
// //      pageBuilder: (BuildContext context, _, __) {
// //        return new ProgressDialog();
// //      }));
// //}
//
// closeProgressDialog(BuildContext context) {
//   Navigator.of(context).pop();
// }
//
// writeDataLocally({String key, String value}) async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   localData.setString(key, value);
// }
//
// writeBoolDataLocally({String key, bool value}) async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   localData.setBool(key, value);
// }
//
// getDataLocally({String key}) async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   return localData.get(key);
// }
//
// getStringDataLocally({String key}) async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   return localData.getString(key);
// }
//
// getBoolDataLocally({String key}) async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   return localData.getBool(key) == null ? false : localData.getBool(key);
// }
//
// clearDataLocally() async {
//   Future<SharedPreferences> saveLocal = SharedPreferences.getInstance();
//   final SharedPreferences localData = await saveLocal;
//   localData.clear();
// }
//
// Widget multiImagePickerMap(
//     {Map<int, File> imageList,
//     VoidCallback addNewImage(int position),
//     VoidCallback removeNewImage(int position)}) {
//   int imageLength = imageList.isEmpty ? 1 : imageList.length + 1;
//
//   print("Image length is $imageLength");
//
//   return new Padding(
//     padding: const EdgeInsets.only(left: 15.0, right: 15.0),
//     child: new SizedBox(
//       height: 150.0,
//       child: new ListView.builder(
//           itemCount: imageLength,
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (context, index) {
//             return imageList.isEmpty || imageList[index] == null
//                 ? new Padding(
//                     padding: new EdgeInsets.only(left: 3.0, right: 3.0),
//                     child: new GestureDetector(
//                       onTap: () {
//                         addNewImage(index);
//                       },
//                       child: new Container(
//                         width: 150.0,
//                         height: 150.0,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: <Widget>[
//                             new Icon(
//                               Icons.image,
//                               size: 150.0,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                             new Icon(
//                               Icons.add_circle,
//                               size: 25.0,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                         decoration: new BoxDecoration(
//                           color: Colors.white,
//                           borderRadius:
//                               new BorderRadius.all(new Radius.circular(15.0)),
//                         ),
//                       ),
//                     ),
//                   )
//                 : new Padding(
//                     padding: new EdgeInsets.only(left: 3.0, right: 3.0),
//                     child: new Stack(
//                       children: <Widget>[
//                         new Container(
//                           width: 150.0,
//                           height: 150.0,
//                           decoration: new BoxDecoration(
//                               color: Colors.grey.withAlpha(100),
//                               borderRadius: new BorderRadius.all(
//                                   new Radius.circular(15.0)),
//                               image: new DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: new FileImage(imageList[index]))),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: new CircleAvatar(
//                             backgroundColor: Colors.red[600],
//                             child: new IconButton(
//                                 icon: new Icon(
//                                   Icons.clear,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   removeNewImage(index);
//                                 }),
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//           }),
//     ),
//   );
// }
//
// Widget multiImagePickerList(
//     {List<File> imageList, VoidCallback removeNewImage(int position)}) {
//   return new Padding(
//     padding: const EdgeInsets.only(left: 15.0, right: 15.0),
//     child: imageList == null || imageList.length == 0
//         ? new Container()
//         : new SizedBox(
//             height: 150.0,
//             child: new ListView.builder(
//                 itemCount: imageList.length,
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (context, index) {
//                   return new Padding(
//                     padding: new EdgeInsets.only(left: 3.0, right: 3.0),
//                     child: new Stack(
//                       children: <Widget>[
//                         new Container(
//                           width: 150.0,
//                           height: 150.0,
//                           decoration: new BoxDecoration(
//                               color: Colors.grey.withAlpha(100),
//                               borderRadius: new BorderRadius.all(
//                                   new Radius.circular(15.0)),
//                               image: new DecorationImage(
//                                   fit: BoxFit.cover,
//                                   image: new FileImage(imageList[index]))),
//                         ),
//                         new Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: CircleAvatar(
//                             backgroundColor: Colors.red[600],
//                             child: new IconButton(
//                                 icon: new Icon(
//                                   Icons.clear,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   removeNewImage(index);
//                                 }),
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 }),
//           ),
//   );
// }
//
// Widget buildImages({int index, Map imagesMap}) {
//   return imagesMap.isEmpty
//       ? new Container(
//           width: 150.0,
//           height: 150.0,
//           child: Stack(
//             alignment: Alignment.center,
//             children: <Widget>[
//               new Icon(
//                 Icons.image,
//                 size: 100.0,
//                 color: Colors.white,
//               ),
//               new Icon(
//                 Icons.add_circle,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//           decoration: new BoxDecoration(
//             color: Colors.grey.withAlpha(100),
//           ),
//         )
//       : imagesMap[index] != null
//           ? new Container(
//               width: 150.0,
//               height: 150.0,
//               decoration: new BoxDecoration(
//                   color: Colors.grey.withAlpha(100),
//                   image: new DecorationImage(
//                       fit: BoxFit.cover,
//                       image: new FileImage(imagesMap[index]))),
//             )
//           : new Container(
//               width: 150.0,
//               height: 150.0,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: <Widget>[
//                   new Icon(
//                     Icons.image,
//                     size: 100.0,
//                     color: Colors.white,
//                   ),
//                   new Icon(
//                     Icons.add_circle,
//                     color: Colors.grey,
//                   ),
//                 ],
//               ),
//               decoration: new BoxDecoration(
//                 color: Colors.grey.withAlpha(100),
//               ),
//             );
// }
