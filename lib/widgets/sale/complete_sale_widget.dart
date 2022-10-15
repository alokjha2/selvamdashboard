import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/models/trip.dart';
import 'package:selvam_broilers/services/database.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/services/sale_db.dart';
import 'package:selvam_broilers/services/trip_db.dart';
import 'package:selvam_broilers/services/vehicle_db.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/utils/colors.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/delivery_input_widget.dart';
import '../custom_button.dart';
import '../custom_input.dart';

class CompleteSaleWidget extends StatefulWidget {
  final SaleOrder saleOrder;
  final TripRoute route;
  final String date;

  const CompleteSaleWidget({
    Key? key,
    required this.saleOrder,
    required this.route,
    required this.date,
  }) : super(key: key);

  @override
  _CompleteSaleWidgetState createState() => _CompleteSaleWidgetState();
}

class _CompleteSaleWidgetState extends State<CompleteSaleWidget> {
  TextEditingController _boxesTaken = TextEditingController(text: '0');
  TextEditingController _boxesGiven = TextEditingController(text: '0');
  TextEditingController _chequeNumberController = TextEditingController();

  TextEditingController _cashAmountController = TextEditingController();
  TextEditingController _chequeAmountController = TextEditingController();
  TextEditingController _gpayAmountController = TextEditingController();

  num _smallCount = 0.0;
  num _regularCount = 0.0;
  num _smallKG = 0.0;
  num _regularKG = 0.0;
  double _totalAmountCollected = 0.0;

  bool _isLoading = false;
  bool _isChildShop = false;
  String _errorMessage = '';
  List<PaymentMode> _paymentModes = [];
  bool _isOrderCompleted = false;
  Trip? _selectedTrip;
  List<Trip> _tripList = [];

  PlatformFile? _chequePhoto;
  PlatformFile? _proofPhoto;
  num _paperRate = 0;

  DeliveryInputController _deliveryInputController = DeliveryInputController();
  @override
  void initState() {
    super.initState();
    _isChildShop = widget.saleOrder.shopInfo!.shopType == ShopType.CHILD;

    _isOrderCompleted = widget.saleOrder.orderStatus == OrderStatus.COMPLETED;

    _fetchTripData();
    //getting the paper rate of the shop for today
    Database().getTodayPaperRate().then((value) {
      if (mounted) {
        if (value != null &&
            value.paperRates
                .containsKey(widget.saleOrder.shopInfo!.regionName)) {
          _paperRate = value.paperRates[widget.saleOrder.shopInfo!.regionName];
          if (_paperRate <= 0) {
            _showDisableDialog(context);
          }
        } else {
          _showDisableDialog(context);
        }
        setState(() {});
      }
    });

    if (_isOrderCompleted) {
      _smallCount = widget.saleOrder.deliveredSmallInCount!;
      _regularCount = widget.saleOrder.deliveredRegularInCount!;
      _smallKG = widget.saleOrder.deliveredSmallInKG!;
      _regularKG = widget.saleOrder.deliveredRegularInKG!;
      _boxesTaken.text = widget.saleOrder.boxesTaken.toString();
      _boxesGiven.text = widget.saleOrder.boxesGiven.toString();
      if (widget.saleOrder.paymentInfo != null) {
        _totalAmountCollected =
            widget.saleOrder.paymentInfo!.totalAmount as double;
      }
      if (widget.saleOrder.paymentInfo != null) {
        _totalAmountCollected =
            widget.saleOrder.paymentInfo!.totalAmount as double;
        _paymentModes.addAll(widget.saleOrder.paymentInfo!.paymentModes);
      }
    }
  }

  void _fetchTripData() async {
    _tripList = await TripDatabase().getTodaysInCompleteTrip(widget.date);
    _tripList.removeWhere((element) =>
        !widget.saleOrder.shopInfo!.routeIDs.contains(element.routeID));
    for (var trip in _tripList) {
      trip.routeInfo = await RouteDatabase().getRoute(trip.routeID);
      trip.vehicleInfo = await VehicleDatabase().getVehicles(trip.vehicleID);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showDisableDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            title: Text('No paper rate is set. Please contact admin.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Go Back',
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
                _paperRate <= 0
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(minWidth: 400),
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Column(
                                children: [
                                  _shopDetails(widget.saleOrder),
                                  SizedBox(height: 20),
                                  _orderDetails(widget.saleOrder),
                                  SizedBox(height: 20),
                                  if (widget.saleOrder.orderStatus ==
                                      OrderStatus.PENDING)
                                    DeliveryInputWidget(
                                      controller: _deliveryInputController,
                                      orderID: widget.saleOrder.orderID,
                                      onSmallCountChanged: (int value) {
                                        setState(() {
                                          _smallCount = value;
                                        });
                                      },
                                      onRegularCountChanged: (int value) {
                                        setState(() {
                                          _regularCount = value;
                                        });
                                      },
                                      onBoxCountChanged: (int value) {
                                        // _boxesGiven.text = value.toString();
                                      },
                                      onRegularTotalKGChanged: (double value) {
                                        setState(() {
                                          _regularKG = value;
                                        });
                                      },
                                      onSmallTotalKGChanged: (double value) {
                                        setState(() {
                                          _smallKG = value;
                                        });
                                      },
                                      isOrderComplete: _isOrderCompleted,
                                    ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              constraints: BoxConstraints(minWidth: 400),
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Column(
                                children: [
                                  _textRow(
                                      'Net Weight',
                                      (_smallKG + _regularKG)
                                              .toStringAsFixed(2) +
                                          '  kgs.'),
                                  _textRow('Total Number of Birds',
                                      '${_smallCount + _regularCount} nos.'),
                                  if (!_isChildShop)
                                    _textRow('Paper Rate',
                                        '${(_regularKG + _smallKG).toStringAsFixed(2)} x ${_paperRate.toStringAsFixed(2)} Rs.'),
                                  if (!_isChildShop)
                                    _textRow('Gross Total',
                                        '${_getGrossTotal().toStringAsFixed(2)} Rs.'),
                                  if (!_isChildShop)
                                    _textRow('Discount',
                                        '- ${(_getGrossTotal() - _getNetTotal()).toStringAsFixed(2)} Rs.'),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Divider(
                                      color: grayDark,
                                    ),
                                  ),
                                  if (!_isChildShop)
                                    _textRow(
                                        'Net Total',
                                        '${_getNetTotal().toStringAsFixed(2)} Rs.',
                                        true),
                                  if (!_isChildShop) SizedBox(height: 10),
                                  if (!_isChildShop) _paymentDetails(),
                                  SizedBox(height: 10),
                                  _proofPhotoWidget(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: 10),
                Text(
                  _errorMessage,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Colors.redAccent),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          children: [
                            CustomButton(
                                width: 120,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                text: 'Close'),
                            Visibility(
                              visible: widget.saleOrder.orderStatus !=
                                  OrderStatus.COMPLETED,
                              child: Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: CustomButton(
                                    width: 120,
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();

                                      double cashTotal = double.parse(
                                          _cashAmountController.text.isEmpty
                                              ? '0'
                                              : _cashAmountController.text
                                                  .trim());
                                      double chequeTotal = double.parse(
                                          _chequeAmountController.text.isEmpty
                                              ? '0'
                                              : _chequeAmountController.text
                                                  .trim());
                                      double gpayTotal = double.parse(
                                          _gpayAmountController.text.isEmpty
                                              ? '0'
                                              : _gpayAmountController.text
                                                  .trim());

                                      if (_selectedTrip == null) {
                                        setState(() {
                                          _errorMessage =
                                              'Please select trip details.';
                                        });
                                        return;
                                      }

                                      if ((_smallKG + _regularKG) < 1) {
                                        setState(() {
                                          _errorMessage =
                                              'Please enter delivery details.';
                                        });
                                        return;
                                      }

                                      if (_boxesGiven.text.isEmpty) {
                                        setState(() {
                                          _errorMessage =
                                              'Please enter Number of boxes given.';
                                        });
                                        return;
                                      }

                                      if (_boxesTaken.text.isEmpty) {
                                        setState(() {
                                          _errorMessage =
                                              'Please enter Number of boxes taken.';
                                        });
                                        return;
                                      }

                                      if (_paymentModes.length > 0) {
                                        if (_paymentModes
                                            .contains(PaymentMode.CHEQUE)) {
                                          if (_chequePhoto == null ||
                                              chequeTotal < 1 ||
                                              _chequeNumberController.text
                                                  .trim()
                                                  .isEmpty) {
                                            setState(() {
                                              _errorMessage =
                                                  'Please Enter all the requiredcheque details.';
                                            });
                                            return;
                                          }
                                        }

                                        if (_paymentModes
                                                .contains(PaymentMode.CASH) &&
                                            cashTotal < 1) {
                                          setState(() {
                                            _errorMessage =
                                                'Please Enter cash denominations.';
                                          });
                                          return;
                                        }

                                        if (_paymentModes
                                                .contains(PaymentMode.GPAY) &&
                                            gpayTotal < 1) {
                                          setState(() {
                                            _errorMessage =
                                                'Please Enter GPay cash amount.';
                                          });
                                          return;
                                        }
                                      }

                                      // if (_proofPhoto == null) {
                                      //   setState(() {
                                      //     _errorMessage =
                                      //         'Please take a proof photo.';
                                      //   });
                                      //   return;
                                      // }

                                      setState(() {
                                        _errorMessage = '';
                                      });

                                      // show the submit confirmation dialog
                                      bool confirm = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmation'),
                                            content: Text(
                                                'Are your sure want to submit the order?\nThis process cannot be undone.'),
                                            actions: [
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Submit'),
                                                onPressed: () async {
                                                  Navigator.pop(context, true);
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                      if (!confirm) return;

                                      var order = widget.saleOrder;
                                      order.deliveredRegularInCount =
                                          _regularCount;
                                      order.deliveredRegularInKG = _regularKG;
                                      order.deliveredSmallInCount = _smallCount;
                                      order.deliveredSmallInKG = _smallKG;
                                      order.completedTime = DateTime.now();

                                      order.boxesGiven = double.parse(
                                          _boxesGiven.text.isEmpty
                                              ? '0'
                                              : _boxesGiven.text.trim());
                                      order.boxesTaken = double.parse(
                                          _boxesTaken.text.isEmpty
                                              ? '0'
                                              : _boxesTaken.text.trim());
                                      order.kgTotal = (_smallKG + _regularKG);
                                      order.countTotal =
                                          (_smallCount + _regularCount);
                                      order.grossTotal = _getGrossTotal();
                                      order.netTotal = _getNetTotal();

                                      order.tripID = _selectedTrip!.docID;
                                      order.driverID = _selectedTrip!.driverID;
                                      order.loadManIDs =
                                          _selectedTrip!.loadManIDs;
                                      order.vehicleID =
                                          _selectedTrip!.vehicleID;

                                      order.inputValues =
                                          _deliveryInputController
                                              .getAllInputValues();

                                      order.paperRate = _paperRate;
                                      order.smallRatePerKG = _paperRate -
                                          widget.saleOrder.shopInfo!
                                              .smallDiscountPerKG;
                                      order.regularRatePerKG = _paperRate -
                                          widget.saleOrder.shopInfo!
                                              .regularDiscountPerKG;
                                      order.smallDiscountPerKG = widget
                                          .saleOrder
                                          .shopInfo!
                                          .smallDiscountPerKG;
                                      order.regularDiscountPerKG = widget
                                          .saleOrder
                                          .shopInfo!
                                          .regularDiscountPerKG;

                                      var statusCache = order.orderStatus;
                                      order.orderStatus = OrderStatus.COMPLETED;

                                      var denominations = {
                                        '2000': int.parse(
                                            den2000.text.trim().isEmpty
                                                ? '0'
                                                : den2000.text.trim()),
                                        '500': int.parse(
                                            den500.text.trim().isEmpty
                                                ? '0'
                                                : den500.text.trim()),
                                        '200': int.parse(
                                            den200.text.trim().isEmpty
                                                ? '0'
                                                : den200.text.trim()),
                                        '100': int.parse(
                                            den100.text.trim().isEmpty
                                                ? '0'
                                                : den100.text.trim()),
                                        '50': int.parse(
                                            den50.text.trim().isEmpty
                                                ? '0'
                                                : den50.text.trim()),
                                        '20': int.parse(
                                            den20.text.trim().isEmpty
                                                ? '0'
                                                : den20.text.trim()),
                                        '10': int.parse(
                                            den10.text.trim().isEmpty
                                                ? '0'
                                                : den10.text.trim()),
                                      };

                                      ShopPayment payment = ShopPayment(
                                          shopID: order.shopID,
                                          paymentTime: DateTime.now(),
                                          totalAmount: _totalAmountCollected,
                                          cashAmount: cashTotal,
                                          chequeAmount: chequeTotal,
                                          gpayAmount: gpayTotal,
                                          paymentModes: _paymentModes,
                                          paidTo: PaidTo.DRIVER,
                                          driverID: _selectedTrip!.driverID,
                                          denominations: denominations,
                                          chequeNumber: _chequeNumberController
                                              .text
                                              .trim(),
                                          saleOrderID: order.orderID);

                                      showOverlayProgress();

                                      bool res = await SaleOrderDatabase()
                                          .submitSaleOrder(
                                        order: order,
                                        chequePhoto: _chequePhoto,
                                        proofPhoto: _proofPhoto,
                                        payment: payment,
                                        trip: _selectedTrip!,
                                        isChildShop: _isChildShop,
                                      );
                                      hideOverlayProgress();
                                      if (res) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delivery success!'),
                                              content:
                                                  Text('Delivery success.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        widget.saleOrder.orderStatus =
                                            statusCache;
                                        showToast(
                                            message:
                                                'Unable to complete delivery. Try again.',
                                            color: red);
                                      }
                                    },
                                    text: 'SUBMIT'),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _proofPhotoWidget() {
    return Container(
      // width: 340,
      child: Column(
        children: [
          Divider(
            endIndent: 20,
            indent: 20,
            color: grayDark,
          ),
          _textRow('Old Boxes In Shop',
              '${widget.saleOrder.shopInfo!.boxesInShop} Nos.'),
          SizedBox(height: 15),
          Visibility(
            visible: !_isOrderCompleted,
            child: Column(
              children: [
                Container(
                  // width: 340,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number of Boxes given',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: secondaryTextDark)),
                        Row(children: [
                          CustomInputField(
                            controller: _boxesGiven,
                            keyboardType: TextInputType.number,
                            hint: 'Count',
                            textInputFormatter: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ], // Only numbers can be entered
                            width: 120,
                            onChanged: () {
                              setState(() {});
                            },
                            readOnly: _isOrderCompleted,
                          ),
                        ]),
                      ]),
                ),
                SizedBox(height: 15),
                Container(
                  // width: 340,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number of Boxes Taken',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: secondaryTextDark)),
                        Row(children: [
                          CustomInputField(
                            controller: _boxesTaken,
                            keyboardType: TextInputType.number,
                            hint: 'Count',
                            width: 120,
                            textInputFormatter: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ], //
                            onChanged: () {
                              setState(() {});
                            },
                            readOnly: _isOrderCompleted,
                          ),
                        ]),
                      ]),
                ),
                SizedBox(height: 15),
                UploadButton(
                  width: double.infinity,
                  onSelectPressed: () async {
                    _proofPhoto = await showImagePicker(true);
                    setState(() {});
                  },
                  onClearPressed: () {
                    setState(() {
                      _proofPhoto = null;
                    });
                  },
                  label: 'Proof Image',
                  fileName: _proofPhoto == null ? null : _proofPhoto!.name,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopDetails(SaleOrder order) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: grayLite, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Details',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Divider(
            color: grayDark,
          ),
          SizedBox(height: 15),
          Table(
            children: [
              _textDataRow('Shop Name', order.shopInfo!.shopName),
              _textDataRow('Owner Name', order.shopInfo!.ownerName),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Text('Phone',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: secondaryTextDark))
                  ]),
                ),
                Material(
                  color: grayLite,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.shopInfo!.phoneNumber,
                              style: Theme.of(context).textTheme.bodyText2),
                          InkWell(
                            child: Icon(
                              Icons.call,
                              color: gray,
                            ),
                            onTap: () {},
                          )
                        ]),
                  ),
                )
              ]),
              _textDataRow('Address', order.shopInfo!.address),
              _textDataRow('Region', order.shopInfo!.regionName),
              if (order.shopInfo!.location!.latitude != 0)
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      Text('Map Location',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: secondaryTextDark))
                    ]),
                  ),
                  Material(
                    color: grayLite,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.map,
                                color: mateBlack,
                              ),
                              onTap: () {},
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {},
                              child: Text('(Tap to open Google maps)',
                                  style: Theme.of(context).textTheme.caption),
                            )),
                          ]),
                    ),
                  )
                ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderDetails(SaleOrder order) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: grayLite, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Divider(
            color: grayDark,
          ),
          SizedBox(height: 15),
          Table(
            children: [
              _textDataRow('Order ID', order.orderID),
              _textDataRow('Delivery date', (widget.saleOrder.orderDate)),
              _textDataRow('Regular',
                  '${order.regularInKG} KG ' + _getCount(order.regularInCount)),
              _textDataRow('Small',
                  '${order.smallInKG} KG ' + _getCount(order.smallInCount)),
              _textDataRow(
                  'Per Small Chicken weight',
                  (widget.saleOrder.smallWeightRef.toStringAsFixed(2)) +
                      ' KGs.'),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Select Trip (${widget.date})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: secondaryTextDark)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<Trip>(
                    style: Theme.of(context).textTheme.bodyText2,
                    value: _selectedTrip,
                    isExpanded: true,
                    hint: Text('Select Trip'),
                    items: [
                      DropdownMenuItem<Trip>(
                        child: Text('Select Trip'),
                        onTap: () {
                          _selectedTrip = null;
                        },
                      ),
                      ..._tripList.map((Trip value) {
                        return DropdownMenuItem<Trip>(
                          value: value,
                          child: Text((value.routeInfo?.routeName ?? '') +
                              ' - ' +
                              (value.vehicleInfo?.vehicleNumber ?? '')),
                        );
                      }).toList()
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTrip = newValue;
                      });
                    },
                  ),
                )
              ])
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentDetails() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('Cash', () {
                if (_isOrderCompleted) return;
                setState(() {
                  if (!_paymentModes.contains(PaymentMode.CASH)) {
                    _paymentModes.add(PaymentMode.CASH);
                  } else {
                    den2000.text = '';
                    den500.text = '';
                    den200.text = '';
                    den100.text = '';
                    den50.text = '';
                    den20.text = '';
                    den10.text = '';
                    _cashAmountController.text = '';
                    _updateCashTotal();
                    _paymentModes.remove(PaymentMode.CASH);
                  }
                });
              }, _paymentModes.contains(PaymentMode.CASH)),
              Visibility(
                visible: _paymentModes.contains(PaymentMode.CASH) &&
                    !_isOrderCompleted,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _denominationRow('2000', den2000, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('500', den500, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('200', den200, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('100', den100, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('50', den50, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('20', den20, false, () {
                        _updateCashTotal();
                      }),
                      _denominationRow('10', den10, false, () {
                        _updateCashTotal();
                      }),
                      SizedBox(height: 5),
                      CustomInputField(
                        controller: _cashAmountController,
                        keyboardType: TextInputType.number,
                        hint: 'Amount',
                        width: 120,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_paymentModes.contains(PaymentMode.CASH) && !_isOrderCompleted)
            SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('Cheque', () {
                if (_isOrderCompleted) return;
                setState(() {
                  if (!_paymentModes.contains(PaymentMode.CHEQUE)) {
                    _paymentModes.add(PaymentMode.CHEQUE);
                  } else {
                    _chequeNumberController.text = '';
                    _chequeAmountController.text = '';
                    _chequePhoto = null;
                    _updateCashTotal();
                    _paymentModes.remove(PaymentMode.CHEQUE);
                  }
                });
              }, _paymentModes.contains(PaymentMode.CHEQUE)),
              Visibility(
                  visible: _paymentModes.contains(PaymentMode.CHEQUE) &&
                      !_isOrderCompleted,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 15),
                      UploadButton(
                        width: 200,
                        onSelectPressed: () async {
                          _chequePhoto = await showImagePicker(true);
                          setState(() {});
                        },
                        onClearPressed: () {
                          setState(() {
                            _chequePhoto = null;
                          });
                        },
                        label: 'Cheque Image',
                        fileName:
                            _chequePhoto == null ? null : _chequePhoto!.name,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomInputField(
                        controller: _chequeNumberController,
                        keyboardType: TextInputType.number,
                        hint: 'Cheque No.',
                        width: 120,
                        onChanged: () {
                          setState(() {});
                        },
                        readOnly: _isOrderCompleted,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomInputField(
                        controller: _chequeAmountController,
                        keyboardType: TextInputType.number,
                        hint: 'Amount',
                        width: 120,
                        onChanged: () {
                          _updateCashTotal();
                        },
                        readOnly: _isOrderCompleted,
                      ),
                    ],
                  )),
            ],
          ),
          if (_paymentModes.contains(PaymentMode.CHEQUE) && !_isOrderCompleted)
            SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('GPay', () {
                if (_isOrderCompleted) return;
                setState(() {
                  if (!_paymentModes.contains(PaymentMode.GPAY)) {
                    _paymentModes.add(PaymentMode.GPAY);
                  } else {
                    _gpayAmountController.text = '';
                    _updateCashTotal();
                    _paymentModes.remove(PaymentMode.GPAY);
                  }
                });
              }, _paymentModes.contains(PaymentMode.GPAY)),
              Visibility(
                visible: _paymentModes.contains(PaymentMode.GPAY) &&
                    !_isOrderCompleted,
                child: CustomInputField(
                  controller: _gpayAmountController,
                  keyboardType: TextInputType.number,
                  hint: 'Amount',
                  width: 120,
                  onChanged: () {
                    _updateCashTotal();
                  },
                  readOnly: _isOrderCompleted,
                ),
              ),
            ],
          ),
          if (_paymentModes.contains(PaymentMode.GPAY) && !_isOrderCompleted)
            SizedBox(height: 20),
          Divider(
            color: grayDark,
          ),
          if (!_isChildShop)
            _textRow('Total Amount Collected',
                '${_totalAmountCollected.toStringAsFixed(2)} Rs.', true),
          SizedBox(height: 5),
          if (!_isChildShop)
            _textRow('Closing Balance\nafter payment',
                '${_getClosingBalance().round().toString()} Rs.', false),
        ],
      ),
    );
  }

  Widget _checkBox(String label, Function onSelected, bool isSelected) {
    return Container(
      width: 120,
      child: TextButton(
        onPressed: () {
          onSelected();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyText2),
            SizedBox(width: 2),
            Icon(
              isSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank,
              color: primaryTextDark,
            )
          ],
        ),
      ),
    );
  }

  var den2000 = TextEditingController();
  var den500 = TextEditingController();
  var den200 = TextEditingController();
  var den100 = TextEditingController();
  var den50 = TextEditingController();
  var den20 = TextEditingController();
  var den10 = TextEditingController();
  Widget _denominationRow(String label, TextEditingController controller,
      bool readOnly, Function onChanged) {
    return Container(
      width: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(' x ',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText2),
          ),
          CustomInputField(
            controller: controller,
            keyboardType: TextInputType.number,
            hint: 'Count',
            width: 60,
            height: 30,
            readOnly: readOnly,
            onChanged: () {
              onChanged();
            },
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], //
          ),
        ],
      ),
    );
  }

  TableRow _textDataRow(String label, String text) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: secondaryTextDark)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText2),
      ),
    ]);
  }

  Widget _textRow(String label, String value, [isBold = false]) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? Theme.of(context).textTheme.headline4
                  : Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: secondaryTextDark)),
          Text(value,
              style: isBold
                  ? Theme.of(context).textTheme.headline4
                  : Theme.of(context).textTheme.bodyText2)
        ],
      ),
    );
  }

  String _getCount(num count) {
    if (count > 0) {
      return '($count nos.)';
    } else {
      return '';
    }
  }

  double _getGrossTotal() {
    double wCost = _smallKG * (_paperRate) as double;
    double bCost = _regularKG * (_paperRate) as double;

    return wCost + bCost;
  }

  double _getNetTotal() {
    double wCost = _smallKG *
        (_paperRate + -widget.saleOrder.shopInfo!.smallDiscountPerKG);

    double bCost = _regularKG *
        (_paperRate + -widget.saleOrder.shopInfo!.regularDiscountPerKG);

    return wCost + bCost;
  }

  double _getClosingBalance() {
    if (_isOrderCompleted) return widget.saleOrder.shopInfo!.closingBalance;
    double ac = _totalAmountCollected;
    return widget.saleOrder.shopInfo!.closingBalance + _getNetTotal() - ac;
  }

  void _updateTotalAmountCollected() {
    double cashTotal = double.parse(_cashAmountController.text.isEmpty
        ? '0'
        : _cashAmountController.text.trim());
    double chequeTotal = double.parse(_chequeAmountController.text.isEmpty
        ? '0'
        : _chequeAmountController.text.trim());
    double gpayTptal = double.parse(_gpayAmountController.text.isEmpty
        ? '0'
        : _gpayAmountController.text.trim());

    setState(() {
      _totalAmountCollected = cashTotal + chequeTotal + gpayTptal;
    });
  }

  void _updateCashTotal() {
    var denominations = {
      2000: int.parse(den2000.text.trim().isEmpty ? '0' : den2000.text.trim()),
      500: int.parse(den500.text.trim().isEmpty ? '0' : den500.text.trim()),
      200: int.parse(den200.text.trim().isEmpty ? '0' : den200.text.trim()),
      100: int.parse(den100.text.trim().isEmpty ? '0' : den100.text.trim()),
      50: int.parse(den50.text.trim().isEmpty ? '0' : den50.text.trim()),
      20: int.parse(den20.text.trim().isEmpty ? '0' : den20.text.trim()),
      10: int.parse(den10.text.trim().isEmpty ? '0' : den10.text.trim()),
    };

    double total = 0;
    denominations.forEach((key, value) {
      total += key * value;
    });

    setState(() {
      _cashAmountController.text = total.toStringAsFixed(2);
    });

    _updateTotalAmountCollected();
  }

  void showOverlayProgress() {
    setState(() {
      _isLoading = true;
    });
  }

  void hideOverlayProgress() {
    setState(() {
      _isLoading = false;
    });
  }
}
