import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:kannapy/models/faq_Q_n_A.dart';
import 'package:kannapy/nm_box.dart';
import 'package:kannapy/tools/policy_Dialog.dart';
import 'package:kannapy/tools/uiFunctions.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'About Us',
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(14),
        children: [
          neumorphicTile(
            padding: 12,
            anyWidget: Column(
              children: [
                Container(
                  decoration: nMBoxCirc,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/kannapyLogo.png'),
                        height: 50,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Center(
                    child: Text(
                  'About Kannapy',
                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: 10.0,
                ),
                RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        children: [
                          TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25.0),
                          ),
                          TextSpan(
                            text:
                                "Kannapy is an invite-only seed vault that is geared to bring breeders, collectors and cultivators the most exclusive and rarest cannabis genetics available on the market today.\n\n",
                          ),
                          TextSpan(
                              text:
                                  "At Kannapy, we are committed to sourcing the finest cannabis genetics and bringing the most exclusive offerings to a private community of like-minded collectors\nOur Member Offerings include:\n\n"),
                          TextSpan(
                              text:
                                  "-Exclusive time sensitive, one-time offerings, on sought after genetics from the some of the worlds most creative and decorated breeders.\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  "-We bring you daily auctions on rare genetics direct from the breeders vault.\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  "-Kannapy will also be launching one of the worlds first pollen bank in January 2021.\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  "-Kannapy will also be launching Kannapy TV. Bringing you exclusive behind the scene footage and interviews with breeders, cannabis cups and so much more.Invitations are currently open but will close on December 31st 2020. After which access will be by the discretion of theDownload the app and Enter LAUNCH2020 for full access\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          neumorphicTile(
            anyWidget: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                Center(
                  child: Text(
                    "FAQ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Divider(),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: faqANS.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Neumorphic(
                        style: NeumorphicStyle(
                            color: Colors.white,
                            shape: NeumorphicShape.flat,
                            depth: -4,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(20))),
                        child: ExpansionTile(
                          title: Text(
                            faqQS[index],
                            style: TextStyle(color: Colors.black),
                          ),
                          childrenPadding: EdgeInsets.all(12),
                          children: [
                            Text(faqANS[index]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: neumorphicTile(
                padding: 12,
                anyWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () => showDialog(
                              context: context,
                              builder: (context) =>
                                  PolicyDialog(mdFileName: "privacy_policy.md"),
                            ),
                        child: Text(
                          "View our privacy policy",
                          style: TextStyle(color: Colors.blue),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () => showDialog(
                              context: context,
                              builder: (context) =>
                                  PolicyDialog(mdFileName: "terms_n_cond.md"),
                            ),
                        // Navigator.of(context).push(
                        // MaterialPageRoute(
                        //     builder: (context) => TermsAndConditions())),
                        child: Text(
                          "View Terms And Conditions",
                          style: TextStyle(color: Colors.blue),
                        )),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
