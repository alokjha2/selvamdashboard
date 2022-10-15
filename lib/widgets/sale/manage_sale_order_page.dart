import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/pages/home_page.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/widgets/sale/sale_detail_widget.dart';
import 'package:selvam_broilers/widgets/sale/sale_request_list_dialog.dart';
import '../../models/sale_order.dart';
import 'package:selvam_broilers/services/sale_db.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/sale/create_sale_order.dart';
import 'package:selvam_broilers/widgets/sale/sale_order_data_table.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../custom_button.dart';
import 'complete_sale_widget.dart';

class ManageSaleOrdersWidget extends StatefulWidget {
  @override
  _ManageSaleOrdersWidgetState createState() => _ManageSaleOrdersWidgetState();
}

class _ManageSaleOrdersWidgetState extends State<ManageSaleOrdersWidget> {
  SaleOrderDatabase _saleDB = SaleOrderDatabase();
  ChildStateUpdateController _childStateUpdateController =
      ChildStateUpdateController();
  ChildStateUpdateController _childStateUpdateController2 =
      ChildStateUpdateController();
  List<SaleOrder> _salesList = [];
  List<SaleOrder> _unassignedSaleList = [];
  DateTime _selectedDateTime = DateTime.now();
  List<TripRoute>? _routeList;
  // Future<List<Shop>?>? _shopFeature;
  Stream<QuerySnapshot>? _saleOrderStream;
  Stream<QuerySnapshot>? _unassignedSaleOrderStream;
  Map<String, Shop>? _shopMap;
  double _smallKG = 0;
  double _smallCount = 0;
  double _regularCount = 0;
  double _regularKG = 0;

  @override
  void initState() {
    super.initState();
    // prevDate = getFormattedDate(_selectedDateTime);
    RouteDatabase().listenRoutes().listen((snap) {
      _routeList = [];
      snap.docs.forEach((doc) {
        _routeList!.add(TripRoute.fromFirestore(doc));
      });
      if (mounted) setState(() {}); //to update the new _routeList
      if (_saleOrderStream == null) {
        _refreshQuery();
      }
    });

    ShopDatabase().getAllShops().then((shops) {
      _shopMap = {};
      shops.forEach((shop) {
        _shopMap![shop.docID!] = shop;
      });

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
                left: 0, top: isPhoneSelected ? 0 : 40, bottom: 0),
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              border: Border.all(
                color: primaryBorder,
              ),
            ),
            child: _routeList == null || _shopMap == null
                ? Center(child: CircularProgressIndicator())
                : _routeList!.isEmpty
                    ? Center(child: Text('No Routes found!'))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _unassignedSaleOrderStream,
                        builder: (context, unassignedOrderSnap) {
                          if (unassignedOrderSnap.hasData) {
                            //show dialog
                            int slNo = 1;
                            _unassignedSaleList.clear();
                            unassignedOrderSnap.data!.docs.forEach((doc) {
                              SaleOrder sale = SaleOrder.fromFirestore(doc);
                              if (_shopMap![sale.shopID] != null) {
                                sale.shopInfo = _shopMap![sale.shopID];
                              }
                              sale.slNo = slNo;
                              _unassignedSaleList.add(sale);
                              slNo++;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // Add Your Code here.
                              _childStateUpdateController2.updateState?.call();
                            });
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                          return StreamBuilder<QuerySnapshot>(
                              stream: _saleOrderStream!,
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> saleSnapshot) {
                                if (saleSnapshot.hasError) {
                                  return Text('Something went wrong');
                                }

                                if (saleSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                _salesList.clear();
                                int slNo = 1;
                                saleSnapshot.data!.docs.forEach((doc) {
                                  SaleOrder sale = SaleOrder.fromFirestore(doc);
                                  if (_shopMap![sale.shopID] != null) {
                                    sale.shopInfo = _shopMap![sale.shopID];
                                  }
                                  sale.slNo = slNo;
                                  _salesList.add(sale);
                                  slNo++;
                                });

                                //calculating total received sale orders
                                _smallKG = 0;
                                _smallCount = 0;
                                _regularCount = 0;
                                _regularKG = 0;
                                _salesList.forEach((sale) {
                                  _smallKG += sale.smallInKG;
                                  _smallCount += sale.smallInCount;
                                  _regularKG += sale.regularInKG;
                                  _regularCount += sale.regularInCount;
                                });

                                saleSnapshot.data!.docChanges.forEach((change) {
                                  if (change.type ==
                                          DocumentChangeType.modified ||
                                      change.type ==
                                          DocumentChangeType.removed) {
                                    this
                                        ._childStateUpdateController
                                        .updateState
                                        ?.call();
                                  }
                                });
                                this
                                    ._childStateUpdateController
                                    .updateState
                                    ?.call();

                                return Row(
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                                width: 1.0, color: gray),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(0),
                                            itemCount: _routeList!.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return _listTile(
                                                  _routeList![index], index);
                                            }),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 10,
                                      child: Column(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: SaleOrderDataTable(
                                              actionButton: Row(
                                                children: [
                                                  CustomIconButton(
                                                    onPressed: () {
                                                      _showRequestListDialog(
                                                          context);
                                                    },
                                                    icon: Stack(
                                                      children: [
                                                        Center(
                                                          child: Icon(
                                                            Icons.list_alt,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: SizedBox(
                                                            width: 30,
                                                            height: 30,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.circle,
                                                                  color: red,
                                                                  size: 20,
                                                                ),
                                                                Text(
                                                                  '${_unassignedSaleList.length}',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText1!
                                                                      .copyWith(
                                                                          color:
                                                                              white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  CustomIconButton(
                                                    onPressed: () {
                                                      if (daysBetween(
                                                              DateTime.now(),
                                                              _selectedDateTime) <
                                                          0) {
                                                        showToast(
                                                            message:
                                                                'Couldn\'t create order for past date.\nPlease select a different date.');
                                                        return;
                                                      }

                                                      var shopList = _shopMap!
                                                          .values
                                                          .toList()
                                                          .where((element) => element
                                                              .routeIDs
                                                              .contains(_routeList![
                                                                      _selectedRouteIndex]
                                                                  .docID))
                                                          .toList();
                                                      _showCreateDialog(
                                                          context, shopList);
                                                    },
                                                    icon: Icon(
                                                        Icons.add_box_rounded),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width: 140,
                                                    child: DateTimePicker(
                                                      textAlign: TextAlign.left,
                                                      type: DateTimePickerType
                                                          .date,
                                                      dateMask: 'd MMM, yyyy',
                                                      initialValue:
                                                          _selectedDateTime
                                                              .toString(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2100),
                                                      icon: Icon(Icons.event),
                                                      dateLabelText: 'Date',
                                                      use24HourFormat: false,
                                                      locale:
                                                          Locale('en', 'US'),
                                                      selectableDayPredicate:
                                                          (date) {
                                                        return true;
                                                      },
                                                      onChanged: (val) {
                                                        _selectedDateTime =
                                                            DateTime.parse(val);
                                                        _refreshQuery();
                                                      },
                                                      validator: (val) {
                                                        return null;
                                                      },
                                                      onSaved: (val) =>
                                                          print(val),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              saleList: _salesList,
                                              isPastDateSelected: daysBetween(
                                                      DateTime.now(),
                                                      _selectedDateTime) <
                                                  0,
                                              stateUpdater:
                                                  _childStateUpdateController,
                                              onRowPressed:
                                                  (SaleOrder sale) async {
                                                _showDetailsDialog(
                                                    context, sale);
                                              },
                                              onDeletePressed:
                                                  (SaleOrder sale) async {
                                                if (daysBetween(DateTime.now(),
                                                        _selectedDateTime) <
                                                    0) {
                                                  showToast(
                                                      message:
                                                          'Unable to delete order for past dates.');
                                                  return;
                                                }
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: Text('Confirmation'),
                                                    content: Text(
                                                        'Sure want to delete sales ${sale.orderID}?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'Cancel'),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          bool res = await _saleDB
                                                              .deleteSaleOrder(
                                                                  data: sale);
                                                          if (res) {
                                                            Navigator.pop(
                                                                context);
                                                            showToast(
                                                                message:
                                                                    'Sale deleted!');
                                                          } else {
                                                            showToast(
                                                                message:
                                                                    'Operation Failed!',
                                                                color: red);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              onEditPressed: (SaleOrder sale) {
                                                if (daysBetween(DateTime.now(),
                                                        _selectedDateTime) <
                                                    0) {
                                                  showToast(
                                                      message:
                                                          'Unable to modify order for past dates.');
                                                  return;
                                                }
                                                _showEditDialog(context, sale);
                                              },
                                              onOrderCompletePressed:
                                                  (SaleOrder order) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8.0)), //this right here
                                                      child: CompleteSaleWidget(
                                                        saleOrder: order,
                                                        route: _routeList![
                                                            _selectedRouteIndex],
                                                        date: getFormattedDate(
                                                            _selectedDateTime),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Received Sale orders:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
                                                ),
                                                Table(
                                                  border: TableBorder.all(
                                                      width: 0.5),
                                                  columnWidths: {
                                                    0: FlexColumnWidth(2),
                                                    1: FlexColumnWidth(6),
                                                    2: FlexColumnWidth(6),
                                                  },
                                                  children: [
                                                    TableRow(children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          'Regular Chicken ',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          '${_regularKG} KGs.',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          '${_regularCount} Nos.',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                    ]),
                                                    TableRow(children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          'Small Chicken',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle1,
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            '${_smallKG} KGs.',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1,
                                                          )),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            '${_smallCount} Nos.',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1,
                                                          )),
                                                    ]),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              });
                        }),
          ),
          if (!isPhoneSelected)
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Sale Orders',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
        ],
      ),
    );
  }

  String prevDate = '';
  void _refreshQuery() {
    _saleOrderStream = _saleDB.listenSaleOrdersForRoute(
        getFormattedDate(_selectedDateTime), _routeList![_selectedRouteIndex]);

    if (getFormattedDate(_selectedDateTime) != prevDate) {
      prevDate = getFormattedDate(_selectedDateTime);
      _unassignedSaleOrderStream =
          _saleDB.listenSaleOrdersForUnassigned(prevDate);
    }
    _childStateUpdateController.updateState?.call();
    if (mounted) setState(() {});
  }

  int _selectedRouteIndex = 0;
  Widget _listTile(TripRoute item, int index) {
    bool isSelected = _selectedRouteIndex == index;
    return Container(
      height: 60,
      child: Material(
        color: isSelected ? selectedBGColor.withAlpha(20) : transparent,
        child: InkWell(
          onTap: () {
            if (_selectedRouteIndex == index) return;
            _selectedRouteIndex = index;
            _refreshQuery();
          },
          child: Stack(
            children: [
              Container(
                width: 3,
                height: 60,
                color: isSelected ? primaryDark : transparent,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Text(
                    '${item.routeNumber} - ${item.routeName}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        color: isSelected ? primaryTextDark : unselectedColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(context, List<Shop> shopList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: CreateSaleOrderWidget(
            selectedRoute: _routeList![_selectedRouteIndex],
            shopList: shopList,
            orderDate: getFormattedDate(_selectedDateTime),
          ),
        );
      },
    ).then((value) {
      _childStateUpdateController.updateState?.call();
    });
  }

  void _showEditDialog(BuildContext context, SaleOrder sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: CreateSaleOrderWidget(
            selectedRoute: _routeList![_selectedRouteIndex],
            orderDate: sale.orderDate,
            saleOrder: sale,
          ),
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, SaleOrder sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: SaleOrderDetailsWidget(saleOrder: sale, shop: sale.shopInfo!),
        );
      },
    );
  }

  void _showRequestListDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: SaleRequestListWidget(
            salesList: _unassignedSaleList,
            controller: _childStateUpdateController2,
            routeList: _routeList!,
          ),
        );
      },
    ).then((value) {
      //to refresh table
      if (mounted) {
        // setState(() {});
        _childStateUpdateController.updateState?.call();
      }
    });
  }
}
