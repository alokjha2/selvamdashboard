import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:mime_type/mime_type.dart';
import 'package:selvam_broilers/models/loadman.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/driver_db.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:selvam_broilers/widgets/shop/payents/payment_detail.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/driver.dart';
import '../../services/loadman_db.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../full_screen_imageviewer.dart';

class SaleOrderDetailsWidget extends StatefulWidget {
  final Shop shop;
  final SaleOrder saleOrder;
  const SaleOrderDetailsWidget(
      {Key? key, required this.shop, required this.saleOrder})
      : super(key: key);

  @override
  _SaleOrderDetailsWidgetState createState() => _SaleOrderDetailsWidgetState();
}

class _SaleOrderDetailsWidgetState extends State<SaleOrderDetailsWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TableRow> _inputItemsRegular = [];
  List<TableRow> _inputItemsSmall = [];
  double _regularAvg = 0;
  double _smallAvg = 0;
  Driver? _driver;
  List<LoadMan> _loadMen = [];

  @override
  void initState() {
    super.initState();
    print('init');

    if (widget.saleOrder.inputValues != null) {
      int count = widget.saleOrder.inputValues!['count'];
      double regularTotalKG = 0;
      double smallTotalKG = 0;
      double regularTotalCount = 0;
      double smallTotalCount = 0;

      for (int i = 0; i < count; i++) {
        var item = widget.saleOrder.inputValues!;

        if (item['${i}_chickenType'] == ChickenType.SMALL.index) {
          smallTotalKG += item['${i}_loadWight'] - item['${i}_emptyWight'];
          smallTotalCount += item['${i}_birdCount'];
          _inputItemsSmall.add(_inputValueRow(
              item['${i}_loadWight'],
              item['${i}_emptyWight'],
              item['${i}_loadWight'] - item['${i}_emptyWight'],
              item['${i}_birdCount'],
              item['${i}_boxCount']));
        } else {
          regularTotalKG += item['${i}_loadWight'] - item['${i}_emptyWight'];
          regularTotalCount += item['${i}_birdCount'];
          _inputItemsRegular.add(_inputValueRow(
              item['${i}_loadWight'],
              item['${i}_emptyWight'],
              item['${i}_loadWight'] - item['${i}_emptyWight'],
              item['${i}_birdCount'],
              item['${i}_boxCount']));
        }
      }
      _regularAvg = regularTotalKG / regularTotalCount;
      _smallAvg = smallTotalKG / smallTotalCount;
    }

    DriverDatabase().getDriver(widget.saleOrder.driverID).then((value) {
      if (mounted) {
        setState(() {
          _driver = value;
        });
      }
    });
    LoadManDatabase().getAllLoadMan().then((list) {
      if (mounted) {
        for (var loadMan in list!) {
          if (widget.saleOrder.loadManIDs!.contains(loadMan.docID)) {
            _loadMen.add(loadMan);
          }
        }
        setState(() {});
      }
    });
  }

  TableRow _inputValueRow(load, empty, total, birdCount, boxCount) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text('${load.toStringAsFixed(2)} Kgs.'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text('${empty.toStringAsFixed(2)} Kgs.'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text('${total.toStringAsFixed(2)} Kgs.'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text('${birdCount}'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text('${boxCount}'),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 500,
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
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sales Order Details',
                        style: Theme.of(context).textTheme.headline2!,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Order Info',
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Divider(
                        height: 20,
                        color: gray,
                      ),
                      Container(
                        // width: 500,
                        color: Colors.white,
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(10),
                          },
                          children: [
                            _tableTextRow('Order ID', widget.saleOrder.orderID),
                            _tableTextRow(
                                'Created On',
                                DateFormat('d MMM, yyyy, hh:mm aa')
                                    .format(widget.saleOrder.createdTime)),
                            _tableTextRow(
                                'Order date', widget.saleOrder.orderDate),
                            _tableTextRow(
                                'Regular',
                                '${widget.saleOrder.regularInKG.toStringAsFixed(2)} KG ' +
                                    _getCount(widget.saleOrder.regularInCount)),
                            _tableTextRow(
                                'Small',
                                '${widget.saleOrder.smallInKG.toStringAsFixed(2)} KG ' +
                                    _getCount(widget.saleOrder.smallInCount)),
                            _tableTextRow('Small chicken weight',
                                '${widget.saleOrder.smallWeightRef.toStringAsFixed(2)} KG '),
                          ],
                        ),
                      ),
                      widget.saleOrder.orderStatus == OrderStatus.COMPLETED
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Delivery Info',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 20,
                                  color: gray,
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(5),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(10),
                                    },
                                    children: [
                                      _tableTextRow(
                                          'Delivered On',
                                          DateFormat('d MMM, yyyy, hh:mm aa')
                                              .format(widget
                                                  .saleOrder.completedTime!)),
                                      _tableTextRow(
                                          'Regular',
                                          '${widget.saleOrder.deliveredRegularInKG?.toStringAsFixed(2) ?? ''} KG ' +
                                              _getCount(widget.saleOrder
                                                  .deliveredRegularInCount!)),
                                      _tableTextRow(
                                          'Small',
                                          '${widget.saleOrder.deliveredSmallInKG?.toStringAsFixed(2) ?? ''} KG ' +
                                              _getCount(widget.saleOrder
                                                  .deliveredSmallInCount!)),
                                      _tableTextRow(
                                          'Net Weight',
                                          widget.saleOrder.kgTotal!
                                                  .toStringAsFixed(2) +
                                              '  kgs.'),
                                      _tableTextRow(
                                          'Sale Quantity difference',
                                          (widget.saleOrder.smallInKG +
                                                      widget.saleOrder
                                                          .regularInKG -
                                                      widget.saleOrder.kgTotal!)
                                                  .abs()
                                                  .toStringAsFixed(2) +
                                              '  kgs.'),
                                      _tableTextRow(
                                          'Total Bird Count',
                                          widget.saleOrder.countTotal!
                                                  .toString() +
                                              '  nos.'),
                                      if (widget.saleOrder.inputValues != null)
                                        _tableWidgetRow(
                                            'Delivery Details',
                                            Column(
                                              children: [
                                                Text(
                                                  'Regular',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                                SizedBox(height: 5),
                                                Table(
                                                  border: TableBorder.all(
                                                      width: 1,
                                                      color: grayDark),
                                                  children: [
                                                    TableRow(children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Load',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Empty',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Net Weight',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Bird count',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Box count',
                                                        ),
                                                      ),
                                                    ]),
                                                    ..._inputItemsRegular
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Average Weight : ${_regularAvg.toStringAsFixed(2)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline4,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Small',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline3,
                                                ),
                                                SizedBox(height: 5),
                                                Table(
                                                  border: TableBorder.all(
                                                      width: 1,
                                                      color: grayDark),
                                                  children: [
                                                    TableRow(children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Load',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Empty',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Net Weight',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Bird count',
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 3),
                                                        child: Text(
                                                          'Box count',
                                                        ),
                                                      ),
                                                    ]),
                                                    ..._inputItemsSmall
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Average Weight : ${_smallAvg.toStringAsFixed(2)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline4,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            )),
                                      _tableTextRow(
                                          'Boxes Given',
                                          widget.saleOrder.boxesGiven!
                                                  .toString() +
                                              '  nos.'),
                                      _tableTextRow(
                                          'Boxes Taken',
                                          widget.saleOrder.boxesTaken!
                                                  .toString() +
                                              '  nos.'),
                                      _tableTextRow(
                                          'Regular Discount Per KG',
                                          widget.saleOrder.regularDiscountPerKG!
                                                  .toStringAsFixed(2) +
                                              '  Rs.'),
                                      _tableTextRow(
                                          'Small Discount Per KG',
                                          widget.saleOrder.smallDiscountPerKG!
                                                  .toStringAsFixed(2) +
                                              '  Rs.'),
                                      _tableTextRow('Total Discount',
                                          '${(widget.saleOrder.grossTotal! - widget.saleOrder.netTotal!).toStringAsFixed(2)}  Rs.'),
                                      _tableTextRow(
                                          'Gross Total',
                                          widget.saleOrder.grossTotal!
                                                  .toStringAsFixed(2) +
                                              '  Rs.'),
                                      _tableTextRow(
                                          'Net Total',
                                          widget.saleOrder.netTotal!
                                                  .toStringAsFixed(2) +
                                              '  Rs.'),
                                      if (widget.saleOrder.paymentInfo != null)
                                        _tableTextRow(
                                            'Amount Collected',
                                            widget.saleOrder.paymentInfo!
                                                    .totalAmount
                                                    .toString() +
                                                '  Rs.'),
                                      _tableImageRow(context, 'Proof Photo',
                                          widget.saleOrder.proofImage),
                                      if (widget.saleOrder.paymentInfo != null)
                                        _tableWidgetRow(
                                            'Payment Info',
                                            Row(
                                              children: [
                                                TextButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)), //this right here
                                                            child:
                                                                PaymentDetailWidget(
                                                              payment: widget
                                                                  .saleOrder
                                                                  .paymentInfo!,
                                                              shop: widget.shop,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                        'View Payment Info')),
                                              ],
                                            )),
                                      _tableTextRow('Driver Name',
                                          _driver?.fullName ?? ''),
                                      _tableTextRow(
                                          'Load Men',
                                          _loadMen.isEmpty
                                              ? '-'
                                              : _loadMen
                                                  .map((e) => e.fullName)
                                                  .join(',\n')),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Shop Info',
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Divider(
                        height: 20,
                        color: gray,
                      ),
                      Container(
                        color: Colors.white,
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(10),
                          },
                          children: [
                            _tableTextRow('Shop Name', widget.shop.shopName),
                            _tableTextRow('Owner Name', widget.shop.ownerName),
                            _tableTextRow('Phone', widget.shop.phoneNumber),
                            _tableTextRow('Address', widget.shop.address),
                            _tableTextRow('Region', widget.shop.regionName),
                            _tableTextRow('Closing Balance',
                                widget.shop.closingBalance.toStringAsFixed(2)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            CustomButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              text: 'Close',
              width: 100,
              height: 36,
            ),
            SizedBox(height: 20),
          ],
        ),
      ],
    );
  }

  //}

  String _getCount(num count) {
    if (count > 0) {
      return '($count nos.)';
    } else {
      return '';
    }
  }

  TableRow _tableTextRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          label,
          //    style: Theme.of(context).textTheme.bodyText2
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ':',
              //    style: Theme.of(context).textTheme.bodyText2
            ),
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
                //  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: secondaryTextDark),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  TableRow _tableWidgetRow(String label, Widget child) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          label,
          //    style: Theme.of(context).textTheme.bodyText2
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ':',
              //    style: Theme.of(context).textTheme.bodyText2
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: child,
      ),
    ]);
  }

  TableRow _tableImageRow(
      BuildContext context, String label, Reference? imgRef) {
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
