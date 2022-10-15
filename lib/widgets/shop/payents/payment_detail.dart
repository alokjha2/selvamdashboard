import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/services/collection_agent_db.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as path;

import '../../../models/collection_agent.dart';
import '../../../models/driver.dart';
import '../../../models/shop.dart';
import '../../../services/driver_db.dart';
import '../../../utils/colors.dart';
import '../../../utils/flags.dart';
import '../../../utils/utils.dart';
import '../../custom_button.dart';
import '../../full_screen_imageviewer.dart';

class PaymentDetailWidget extends StatefulWidget {
  final ShopPayment payment;
  final Shop shop;
  const PaymentDetailWidget(
      {Key? key, required this.payment, required this.shop})
      : super(key: key);

  @override
  State<PaymentDetailWidget> createState() => _PaymentDetailWidgetState();
}

class _PaymentDetailWidgetState extends State<PaymentDetailWidget> {
  List<TableRow> _denominationRows = [];

  @override
  void initState() {
    super.initState();
    if (widget.payment.denominations != null) {
      widget.payment.denominations!.forEach((k, v) {
        _denominationRows.add(
          TableRow(children: [
            Text('$k'),
            Text('x'),
            Text('$v'),
          ]),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                'Payment Info',
                style: Theme.of(context).textTheme.headline2!,
              ),
              SizedBox(height: 20),
              Container(
                width: 600,
                color: Colors.white,
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(5),
                  },
                  children: [
                    _tableTextRow('Shop Name', widget.shop.shopName),
                    _tableTextRow('Total Paid',
                        widget.payment.totalAmount.toStringAsFixed(2)),
                    _tableTextRow('Payment Modes',
                        getPaymentText(widget.payment.paymentModes)),
                    _tableTextRow('Total Cash',
                        widget.payment.cashAmount.toStringAsFixed(2)),
                    _tableTextRow('Total Cheque Amount',
                        widget.payment.chequeAmount.toStringAsFixed(2)),
                    _tableTextRow('Closing balance after payment',
                        widget.payment.closingBalance!.toStringAsFixed(2)),
                    _tableTextRow(
                        'Time & Date',
                        getFormattedDateTime(widget.payment.paymentTime,
                            'MMM dd, yyyy hh:mm aa')),
                    _widgetDataRow(
                        'Denominations',
                        Table(
                          children: _denominationRows,
                        )),
                    _widgetDataRow(
                      'Paid to',
                      widget.payment.paidTo == PaidTo.COLLECTOR
                          ? FutureBuilder(
                              future: CollectionAgentDatabase()
                                  .getAgent(widget.payment.agentID),
                              builder: (context,
                                  AsyncSnapshot<CollectionAgent?> data) {
                                if (data.connectionState !=
                                    ConnectionState.done) {
                                  return CircularProgressIndicator();
                                }
                                if (data.data == null) {
                                  return Text('Collection Agent',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2);
                                }
                                return Text(
                                  '${data.data!.fullName} (Collection Agent)',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyText2,
                                );
                              })
                          : FutureBuilder(
                              future: DriverDatabase()
                                  .getDriver(widget.payment.driverID),
                              builder: (context, AsyncSnapshot<Driver?> data) {
                                if (data.connectionState !=
                                    ConnectionState.done) {
                                  return CircularProgressIndicator();
                                }
                                if (data.data == null) {
                                  return Text('Driver',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2);
                                }
                                return Text(
                                  '${data.data!.fullName} (Driver)',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyText2,
                                );
                              }),
                    ),
                    if (widget.payment.chequeNumber != null)
                      _tableTextRow(
                          'Cheque Number', widget.payment.chequeNumber!),
                    if (widget.payment.chequeImage != null)
                      _tableImageRow(
                          'Cheque Photo', widget.payment.chequeImage),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                  width: 80,
                  height: 36,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Close'),
            ],
          )
        ],
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

  TableRow _widgetDataRow(String label, Widget child) {
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
        child: child,
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
