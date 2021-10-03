import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kannapy/tools/progress.dart';
import 'package:kannapy/tools/uiFunctions.dart';
import 'package:kannapy/userScreens/home.dart';

class ManageCodes extends StatefulWidget {
  @override
  _ManageCodesState createState() => _ManageCodesState();
}

class _ManageCodesState extends State<ManageCodes> {
  TextEditingController _createCodeController = TextEditingController();

  DateTime expiryDate;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Center(
              child: FaIcon(
            FontAwesomeIcons.keycdn,
            color: Colors.black,
          )),
          elevation: 10,
          title: TextFormField(
            controller: _createCodeController,
            decoration: InputDecoration(
                hintText: "Create Code",
                filled: false,
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () =>
                      createCode(_createCodeController.text, context),
                )),
          ),
        ),
        body: StreamBuilder(
          stream: codesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return bouncingGridProgress();
            }
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  "Warning Currently No Active codes!!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
              );
            }
            List allCodes = [];
            List allExpiryDates = [];
            snapshot.data.docs.forEach((e) {
              allCodes.add(e.data()['code'].toString());
              allExpiryDates.add(e.data()['expiryDate'].toDate());
            });
            return ListView.separated(
              itemBuilder: (context, index) {
                return Dismissible(
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: Text('DELETE'),
                  ),
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    setState(() {
                      deleteCode(allCodes[index]);
                    });
                    BotToast.showText(text: "Deleted From Database");
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 12.0, left: 8, right: 8),
                    child: neumorphicTile(
                      padding: 2,
                      anyWidget: ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.key,
                          color: Colors.black,
                        ),
                        title: Text("Code : ${allCodes[index]}"),
                        subtitle: Text(allExpiryDates[index]
                                .isBefore(DateTime.now())
                            ? "Code has been Expired"
                            : "Expiry Date : ${allExpiryDates[index].toString()}"),
                        // onLongPress: () => deleteCode(allCodes[index]),
                      ),
                    ),
                  ),
                );
              },
              itemCount: allCodes.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
            );
          },
        ),
      ),
    );
  }

  createCode(String code, BuildContext parentContext) async {
    await showDatePicker(
            context: parentContext,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2024))
        .then((value) {
      setState(() {
        expiryDate = value;
      });
      if (expiryDate != null) {
        handleCode(code, expiryDate);
        _createCodeController.clear();
      } else {
        BotToast.showText(text: "Please re-Enter Expiry Date ");
      }
    });
  }

  void deleteCode(String code) {
    codesRef.doc(code).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
}
