import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../full_screen_imageviewer.dart';

class ShopPaymentWidget extends StatefulWidget {
  final Shop shop;

  const ShopPaymentWidget({
    Key? key,
    required this.shop,
  }) : super(key: key);
  @override
  _ShopPaymentWidgetState createState() => _ShopPaymentWidgetState();
}

class _ShopPaymentWidgetState extends State<ShopPaymentWidget> {
  ShopDatabase db = ShopDatabase();
  late ShopDataSource _dataSource;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  int _rowIndex = 0;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  late List<ShopPayment> _filteredList;
  late List<ShopPayment> paymentList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = paymentList;
    _dataSource = _DataSource(_filteredList);
  }

  ShopDataSource _DataSource(List<ShopPayment> paymentsList) {
    return ShopDataSource(
      context: context,
      paymentsList: paymentsList,
    );
  }

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }

  ScrollController _scrollBar = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            child: Container(
              width: 1000,
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
                primary: true,
                child: Container(
                  constraints:
                      BoxConstraints.tightForFinite(width: 1000, height: 460),
                  color: Colors.white,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: db.listenPayments(widget.shop),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Container(
                          child: Text("Error"),
                        );
                      }

                      if (snapshot.hasData) {
                        paymentList.clear();
                        for (var doc in snapshot.data!.docs) {
                          ShopPayment event = ShopPayment.fromFirestore(doc);
                          paymentList.add(event);
                        }

                        return
                        //  Text("jdehjd");
                        PaginatedDataTable2(
                          header: Center(
                              child: Text(
                            widget.shop.shopName,
                            style: Theme.of(context).textTheme.headline2!,
                          )),
                          scrollController: _scrollBar,
                          availableRowsPerPage: [
                            paymentList.length > 0
                                ? paymentList.length
                                : PaginatedDataTable.defaultRowsPerPage
                          ],
                          horizontalMargin: 10,
                          columnSpacing: 10,
                          showCheckboxColumn: false,
                          wrapInCard: false,
                          rowsPerPage: paymentList.length > 0
                              ? paymentList.length
                              : PaginatedDataTable.defaultRowsPerPage,
                          fit: FlexFit.tight,
                          border: TableBorder(
                              top: BorderSide(color: primaryBorder),
                              bottom: BorderSide(color: primaryBorder),
                              left: BorderSide(color: primaryBorder),
                              right: BorderSide(color: primaryBorder),
                              verticalInside: BorderSide(color: transparent),
                              horizontalInside:
                                  BorderSide(color: primaryBorder, width: 1)),
                          onRowsPerPageChanged: (value) {
                            setState(() {
                              _rowsPerPage = value!;
                            });
                          },
                          initialFirstRowIndex: _rowIndex,
                          onPageChanged: (rowIndex) {
                            setState(() {
                              _rowIndex = rowIndex;
                            });
                          },
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columns: [
                            DataColumn2(
                              size: ColumnSize.S,
                              label: _headerText(text: 'Sl.No'),
                            ),
                            DataColumn2(
                              size: ColumnSize.M,
                              label: _headerText(text: 'Date & Time'),
                            ),
                            DataColumn2(
                              size: ColumnSize.M,
                              label: _headerText(text: 'Paid to'),
                            ),
                            DataColumn2(
                              size: ColumnSize.M,
                              label: _headerText(text: 'Order ID'),
                            ),
                            DataColumn2(
                              size: ColumnSize.L,
                              label: _headerText(text: 'Payment Mode(s)'),
                            ),
                            DataColumn2(
                              size: ColumnSize.M,
                              label: _headerText(text: 'Total Amount'),
                            ),
                            // DataColumn2(
                            //   size: ColumnSize.M,
                            //   label: _headerText(text: 'Closing Balance'),
                            // ),
                          ],
                          empty: Center(
                              child: Text(
                            'No data found!',
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(color: gray),
                          )),
                          source: _dataSource,
                        );
                      }

                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
          ),
          CustomButton(
              width: 80,
              height: 36,
              onPressed: () {
                Navigator.pop(context);
              },
              text: 'Close'),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerText({required String text}) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .subtitle2!
          .copyWith(color: secondaryTextDark),
    );
  }
}

class ShopDataSource extends DataTableSource {
  final BuildContext context;
  late List<ShopPayment> paymentsList;

  ShopDataSource.empty(this.context) {
    paymentsList = [];
  }

  ShopDataSource({
    required this.context,
    required List<ShopPayment> paymentsList,
  }) {
    this.paymentsList = paymentsList;
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= paymentsList.length) throw 'index > _desserts.length';
    final payment = paymentsList[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(_bodyText(text: (payment.slNo + 1 + index).toString())),
        DataCell(_bodyText(
            text: DateFormat('d MMM, yyyy \n hh:mm aa')
                .format(payment.paymentTime))),
        DataCell(_bodyText(
            text: (payment.paidTo == PaidTo.DRIVER)
                ? 'Driver'
                : (payment.paidTo == PaidTo.ADMIN)
                    ? 'Admin'
                    : 'Collector')),
        DataCell(_bodyText(
            text: payment.saleOrderID == null || payment.saleOrderID!.isEmpty
                ? '-'
                : payment.saleOrderID)),
        DataCell(Row(
          children: [
            _bodyText(text: getPaymentText(payment.paymentModes)),
            if (payment.paymentModes.contains(PaymentMode.CASH))
              Container(
                width: 60,
                child: IconButton(
                  onPressed: () {
                    _showDenominationDialog(context, payment.denominations!);
                  },
                  icon: SvgPicture.asset('/icons/checkbook.svg'),
                ),
              ),
            payment.chequeImage == null
                ? Text('',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: red))
                : Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 60,
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FutureBuilder<String>(
                          future: payment.chequeImage!.getDownloadURL(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              String? mimeType = mime(path.basename(payment
                                  .chequeImage!.fullPath
                                  .split('/')
                                  .last));
                              return Container(
                                width: 60,
                                child: IconButton(
                                  onPressed: () {
                                    if (snapshot.hasData) {
                                      _showFullScreenDialog(
                                          context,
                                          snapshot.data!,
                                          payment.chequeImage!.fullPath
                                              .split('/')
                                              .last);
                                    } else {
                                      showToast(message: 'No Image!');
                                    }
                                  },
                                  icon:
                                      SvgPicture.asset('/icons/checkbook.svg'),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          }),
                    ),
                  )
          ],
        )),
        DataCell(
            _bodyText(text: '${payment.totalAmount.toStringAsFixed(2)} Rs.')),
        // DataCell(_bodyText(
        //     text: '${payment.closingBalance.toStringAsFixed(2)} Rs.')),
      ],
    );
  }

  @override
  int get rowCount => paymentsList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  Widget _bodyText({String? text, Color? color}) {
    return Text(
      text ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: color ?? primaryTextDark),
    );
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

  void _showDenominationDialog(
      BuildContext context, Map<dynamic, dynamic> denominations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<TableRow> children = [];
        denominations.forEach((k, v) {
          children.add(
            TableRow(children: [
              Text('$k'),
              Text('x'),
              Text('$v'),
            ]),
          );
        });
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: Container(
            width: 200,
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Denominations',
                  style: Theme.of(context).textTheme.headline2!,
                ),
                SizedBox(height: 20),
                Table(
                  children: children,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
