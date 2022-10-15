import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:mime_type/mime_type.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:selvam_broilers/services/database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../full_screen_imageviewer.dart';

class ShopDetailsWidget extends StatefulWidget {
  final Shop shop;

  const ShopDetailsWidget({Key? key, required this.shop}) : super(key: key);
  @override
  _ShopDetailsWidgetState createState() => _ShopDetailsWidgetState();
}

class _ShopDetailsWidgetState extends State<ShopDetailsWidget> {
  Database db = Database();
  String routes = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    RouteDatabase().getAllRoutes().then((value) {
      if (mounted) {
        setState(() {
          value.forEach((route) {
            if (widget.shop.routeIDs.contains(route.docID)) {
              routes += '${route.routeName} (${route.routeNumber})\n';
            }
          });
          routes = routes.substring(0, routes.length - 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      // scrollDirection: Axis.vertical,
      child: Container(
        height: size.height,
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          border: Border.all(
            color: primaryBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Shop Info',
                        style: Theme.of(context).textTheme.headline2!,
                      ),
                      SizedBox(height: 20),
                      Container(
                        constraints: BoxConstraints(minWidth: 500),
                        color: Colors.white,
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(5),
                          },
                          children: [
                            _tableTextRow('Shop Name', widget.shop.shopName),
                            _tableTextRow('Owner Name', widget.shop.ownerName),
                            _tableTextRow(
                                'Phone Number', widget.shop.phoneNumber),
                            // _tableTextRow(
                            //   "Total", 
                            //   getShopTotal("T3uh1c9DefTO9NehTzkneeJXZ6C3")),
                            _tableTextRow('Address', widget.shop.address),
                            _tableTextRow(
                                'Regular Discount Per KG',
                                widget.shop.regularDiscountPerKG.toString() +
                                    '  Rs.'),
                            _tableTextRow(
                                'Small Discount Per KG',
                                widget.shop.smallDiscountPerKG.toString() +
                                    '  Rs.'),
                            _tableTextRow('Closing balance',
                                '${widget.shop.closingBalance.toStringAsFixed(2)} Rs.'),
                            _tableTextRow('Number of Boxes in shop',
                                '${widget.shop.boxesInShop}'),
                            _tableTextRow('Area', routes),
                            _tableTextRow('Region', widget.shop.regionName),
                            _tableTextRow(
                                'Added on',
                                DateFormat('dd,MMM yyyy : hh:mm:aa')
                                    .format(widget.shop.addedTime)),
                            _tableImageRow('Shop Photo', widget.shop.shopPhoto),
                            _tableImageRow(
                                'Owner Photo', widget.shop.ownerPhoto),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 20),
                CustomButton(
                    width: 80,
                    height: 36,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Close'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _tableTextRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(label, style: Theme.of(context).textTheme.bodyText2),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(':', style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: secondaryTextDark),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  TableRow _tableImageRow(String label, Reference? imgRef) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(label, style: Theme.of(context).textTheme.bodyText2),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(':', style: Theme.of(context).textTheme.bodyText2),
          ],
        ),
      ),
      imgRef == null
          ? Text('No Image',
              style: Theme.of(context).textTheme.caption!.copyWith(color: red))
          : Container(
              width: 100,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: FutureBuilder<String>(
                  future: imgRef.getDownloadURL(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      String? mimeType =
                          mime(path.basename(imgRef.fullPath.split('/').last));
                      final String? extension = extensionFromMime(mimeType!);
                      if (extension == 'pdf') {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              child: Stack(
                                children: [
                                  SfPdfViewer.network(snapshot.data!),
                                  TextButton(
                                    onPressed: () {
                                      if (snapshot.hasData) {
                                        _showFullScreenDialog(
                                            context,
                                            snapshot.data!,
                                            imgRef.fullPath.split('/').last);
                                      } else {
                                        showToast(message: 'No Image!');
                                      }
                                    },
                                    child: Container(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    // height: 80,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.centerLeft,
                                      placeholder: (context, url) => Text(
                                          'Loading...',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(color: gray)),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.error,
                                        color: red,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Container(),
                                    onPressed: () {
                                      if (snapshot.hasData) {
                                        _showFullScreenDialog(
                                            context,
                                            snapshot.data!,
                                            imgRef.fullPath.split('/').last);
                                      } else {
                                        showToast(message: 'No Image!');
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text('No Image',
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(color: red));
                    } else {
                      return Text('Loading...',
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(color: gray));
                    }
                  }),
            ),
    ]);
  }

  // getShopTotal(shopId){
  //   final shop = FirebaseFirestore.instance.collection('sale_orders').where("shopID",isEqualTo: shopId).snapshots();


  //   Text();



  // }

  void _showFullScreenDialog(
      BuildContext context, String url, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: FullScreenImageViewer(
            fileName: fileName,
            url: url,
          ),
        );
      },
    );
  }
}
