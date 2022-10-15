import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../models/return_model.dart';
import '../../models/sale_order.dart';
import '../../models/shop.dart';
import '../../services/sale_db.dart';
import '../../utils/child_callback_controller.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../../widgets/delivery_input_widget.dart';
import '../custom_button.dart';

class ChickenReturnWidget extends StatefulWidget {
  final Shop shop;
  const ChickenReturnWidget({Key? key, required this.shop}) : super(key: key);

  @override
  State<ChickenReturnWidget> createState() => _ChickenReturnWidgetState();
}

class _ChickenReturnWidgetState extends State<ChickenReturnWidget> {
  bool _isLoading = false;
  ChildStateUpdateController _childStateUpdateController =
      ChildStateUpdateController();
  DeliveryInputController _deliveryInputController = DeliveryInputController();
  Future<SaleOrder?>? _saleOrderFuture;
  TextEditingController _boxesTaken = TextEditingController(text: '0');
  TextEditingController _boxesGiven = TextEditingController(text: '0');

  num _smallCount = 0.0;
  num _regularCount = 0.0;
  num _smallKG = 0.0;
  num _regularKG = 0.0;
  num _totalAmountCollected = 0.0;
  bool _isChildShop = false;
  String _errorMessage = '';
  DateTime? _selectedDate;
  SaleOrder? _saleOrder;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
              title: Row(
                children: [
                  Text(
                    'Return Chicken',
                    style: Theme.of(context).textTheme.headline2!,
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: red,
                      size: 24,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              actions: <Widget>[]),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(minWidth: 400),
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width * 0.35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    _shopDetails(widget.shop),
                    SizedBox(height: 20),
                    DeliveryInputWidget(
                      controller: _deliveryInputController,
                      orderID: 'return', //can be any string
                      onSmallCountChanged: (int value) {
                        print('small count ${value}');
                        setState(() {
                          _smallCount = value;
                        });
                      },
                      onRegularCountChanged: (int value) {
                        print('regular count ${value}');
                        setState(() {
                          _regularCount = value;
                        });
                      },
                      onBoxCountChanged: (int value) {
                        // _boxesGiven.text = value.toString();
                      },
                      onRegularTotalKGChanged: (double value) {
                        print('regular total ${value}');
                        setState(() {
                          _regularKG = value;
                        });
                      },
                      onSmallTotalKGChanged: (double value) {
                        print('small total ${value}');
                        setState(() {
                          _smallKG = value;
                        });
                      },
                      isOrderComplete: false,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(minWidth: 400),
                width: MediaQuery.of(context).size.width * 0.35,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivered Date',
                              style: Theme.of(context).textTheme.headline4),
                          Container(
                            width: 170,
                            height: 40,
                            child: OutlinedButton(
                              child: Text(
                                _selectedDate == null
                                    ? 'Select'
                                    : '${_selectedDate!.day.toString()} - ${_selectedDate!.month} - ${_selectedDate!.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .button!
                                    .copyWith(
                                      color: secondaryTextDark,
                                    ),
                              ),
                              onPressed: () async {
                                var now = DateTime.now();
                                var tomorrow = DateFormat('dd-MM-yyyy').parse(
                                    '${now.day}-${now.month}-${now.year}');
                                var nextWeek = DateFormat('dd-MM-yyyy').parse(
                                    '${now.day + 14}-${now.month}-${now.year}');

                                final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        _selectedDate ?? DateTime.now(),
                                    firstDate: new DateTime(
                                        2021, 4, 8), //change year to 2022
                                    lastDate: nextWeek);
                                if (picked != null && picked != _selectedDate)
                                  setState(() {
                                    _selectedDate = picked;
                                    _saleOrderFuture = SaleOrderDatabase()
                                        .getSaleOrderForDate(
                                            getFormattedDate(_selectedDate!),
                                            widget.shop.docID!);
                                    _errorMessage = '';
                                  });
                              },
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0, color: primaryBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _boxDetails(),
                    SizedBox(height: 10),
                    _textRow('Net Weight',
                        (_smallKG + _regularKG).toStringAsFixed(2) + '  kgs.'),
                    _textRow('Total Number of Birds',
                        '${_smallCount + _regularCount} nos.'),
                    SizedBox(height: 10),
                    if (_selectedDate != null)
                      FutureBuilder(
                          future: _saleOrderFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<SaleOrder?> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              _saleOrder = snapshot.data;
                              if (snapshot.data == null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    _errorMessage =
                                        'No orders found for selected Date. Select different date';
                                  });
                                });
                                return Container();
                              } else {
                                var total =
                                    (_smallKG * _saleOrder!.smallRatePerKG!) +
                                        (_regularKG *
                                            _saleOrder!.regularRatePerKG!);

                                return Column(
                                  children: [
                                    _textRow('Regular rate per KG',
                                        '${_saleOrder!.regularRatePerKG!.toStringAsFixed(2)} Rs.'),
                                    _textRow('Small rate per KG',
                                        '${_saleOrder!.smallRatePerKG!.toStringAsFixed(2)} Rs.'),
                                    _textRow('Total Amount ',
                                        '${total.toStringAsFixed(2)} Rs.'),
                                  ],
                                );
                              }
                            } else {
                              return Container();
                            }
                          }),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
          Text(
            _errorMessage,
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: Colors.redAccent),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    onPressed: () async {
                      if (_selectedDate == null || _saleOrder == null) {
                        setState(() {
                          _errorMessage = 'Please select date.';
                        });
                        return;
                      }

                      if (_saleOrder == null) {
                        setState(() {
                          _errorMessage =
                              'No order found for the selected date.';
                        });
                        return;
                      }

                      var totalReturnAmt =
                          (_smallKG * _saleOrder!.smallRatePerKG!) +
                              (_regularKG * _saleOrder!.regularRatePerKG!);

                      if (totalReturnAmt == 0) {
                        setState(() {
                          _errorMessage = 'Total should not be 0.';
                        });
                        return;
                      }

                      if ((_smallKG + _regularKG) < 1 ||
                          (_regularCount + _smallCount) < 1) {
                        setState(() {
                          _errorMessage = 'Please enter delivery details.';
                        });
                        return;
                      }

                      if (_boxesGiven.text.isEmpty) {
                        setState(() {
                          _errorMessage = 'Please enter Number of boxes given.';
                        });
                        return;
                      }

                      if (_boxesTaken.text.isEmpty) {
                        setState(() {
                          _errorMessage = 'Please enter Number of boxes taken.';
                        });
                        return;
                      }

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
                                'Are your sure want to submit the return order?\nThis process cannot be undone.'),
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

                      ReturnModel returnOrder = ReturnModel(
                        createdTime: DateTime.now(),
                        orderDeliveryDate: getFormattedDate(_selectedDate!),
                        shopID: _saleOrder!.shopID,
                        pickupRegularInKG: _regularKG,
                        pickupRegularInCount: _regularCount,
                        pickupSmallInKG: _smallKG,
                        pickupSmallInCount: _smallCount,
                        countTotal: _smallCount + _regularCount,
                        kgTotal: _smallKG + _regularKG,
                        boxesTaken: double.tryParse(_boxesTaken.text) ?? 0,
                        boxesGiven: double.tryParse(_boxesGiven.text) ?? 0,
                        grossTotal: totalReturnAmt,
                        netTotal: totalReturnAmt,
                        smallDiscountPerKG: _saleOrder!.smallDiscountPerKG ?? 0,
                        regularDiscountPerKG:
                            _saleOrder!.regularDiscountPerKG ?? 0,
                        smallRatePerKG: _saleOrder!.smallRatePerKG ?? 0,
                        regularRatePerKG: _saleOrder!.regularRatePerKG ?? 0,
                        paperRate: _saleOrder!.paperRate ?? 0,
                        inputValues:
                            _deliveryInputController.getAllInputValues(),
                      );

                      showOverlayProgress();
                      bool res = await SaleOrderDatabase()
                          .submitChickenReturn(returnOrder: returnOrder);
                      hideOverlayProgress();

                      if (res) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return WillPopScope(
                              onWillPop: () async => false,
                              child: AlertDialog(
                                title: Text('Success!'),
                                content: Text('Return success.'),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        showToast(
                            message: 'Unable to complete return. Try again.',
                            color: red);
                      }
                    },
                    text: 'Submit',
                  ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _shopDetails(Shop shop) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: cardFillColor, borderRadius: BorderRadius.circular(8.0)),
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
              _textDataRow('Shop Name', shop.shopName),
              _textDataRow('Owner Name', shop.ownerName),
              _textDataRow('Phone', shop.phoneNumber),
              _textDataRow('Address', shop.address),
              _textDataRow('Region', shop.regionName),
              if (shop.location!.latitude != 0)
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
                ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boxDetails() {
    return Container(
      child: Column(
        children: [
          Divider(
            endIndent: 20,
            indent: 20,
            color: grayDark,
          ),
          _textRow('Old Boxes In Shop', '${widget.shop.boxesInShop} Nos.'),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
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
                          onChanged: (s) {
                            setState(() {});
                          },
                        ),
                      ]),
                    ]),
                SizedBox(height: 15),
                Row(
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
                          onChanged: (s) {
                            setState(() {});
                          },
                        ),
                      ]),
                    ]),
                SizedBox(height: 15),
              ],
            ),
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

  Widget _textRow(String label, String value,
      [isBold = false, double hPadding = 20]) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 5),
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

  void showOverlayProgress() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
  }

  void hideOverlayProgress() {
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }
}
