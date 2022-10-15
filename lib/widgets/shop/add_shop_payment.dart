import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selvam_broilers/models/shop_payment.dart';
import 'package:selvam_broilers/services/sale_db.dart';
import '../../models/shop.dart';
import '../../utils/colors.dart';
import '../../utils/flags.dart';
import '../../utils/utils.dart';
import '../custom_button.dart';
import '../custom_input.dart';

class PaymentPage extends StatefulWidget {
  final Shop shop;

  const PaymentPage({Key? key, required this.shop}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  String _errorMessage = '';
  double _totalAmountCollected = 0.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Add payment',
                        style: Theme.of(context).textTheme.headline2!,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 400,
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(5),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(5),
                                  },
                                  children: [
                                    _tableTextRow('Shop', widget.shop.shopName),
                                    _tableTextRow('Date',
                                        getFormattedDate(DateTime.now())),
                                  ],
                                ),
                              ),
                              Text('Payment details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(fontWeight: FontWeight.w700)),
                              if (widget.shop.shopType == ShopType.PARENT)
                                _paymentDetails(),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        _errorMessage,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: red),
                      ),
                      SizedBox(height: 15),
                      _isLoading
                          ? CircularProgressIndicator()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomButton(
                                    width: 100,
                                    height: 40,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    text: 'Cancel'),
                                SizedBox(width: 20),
                                CustomButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

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

                                    // try {
                                    _showOverlayProgress();

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
                                      '50': int.parse(den50.text.trim().isEmpty
                                          ? '0'
                                          : den50.text.trim()),
                                      '20': int.parse(den20.text.trim().isEmpty
                                          ? '0'
                                          : den20.text.trim()),
                                      '10': int.parse(den10.text.trim().isEmpty
                                          ? '0'
                                          : den10.text.trim()),
                                    };

                                    ShopPayment payment = ShopPayment(
                                      shopID: widget.shop.docID!,
                                      paymentTime: DateTime.now(),
                                      totalAmount: _totalAmountCollected,
                                      cashAmount: cashTotal,
                                      chequeAmount: chequeTotal,
                                      gpayAmount: gpayTotal,
                                      paymentModes: _paymentModes,
                                      paidTo: PaidTo.ADMIN,
                                      denominations: denominations,
                                      chequeNumber:
                                          _chequeNumberController.text.trim(),
                                    );

                                    bool res = await SaleOrderDatabase()
                                        .submitPayment(
                                            payment: payment,
                                            chequePhoto: _chequePhoto);

                                    if (res) {
                                      Fluttertoast.showToast(
                                          msg: 'Order Created',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: primary,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                          webBgColor:
                                              'linear-gradient(to right, #292A31, #292A31)');
                                      Navigator.of(context).pop();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Unable to create. Try again.',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          webBgColor:
                                              'linear-gradient(to right, #ff0000, #ff0000)',
                                          fontSize: 16.0);
                                    }
                                    _hideOverlayProgress();
                                    // } catch (e) {
                                    //   print(e);
                                    //   Fluttertoast.showToast(
                                    //       msg: 'Unable to create. Try again.',
                                    //       toastLength: Toast.LENGTH_SHORT,
                                    //       gravity: ToastGravity.CENTER,
                                    //       timeInSecForIosWeb: 1,
                                    //       backgroundColor: Colors.red,
                                    //       textColor: Colors.white,
                                    //       webBgColor:
                                    //           'linear-gradient(to right, #ff0000, #ff0000)',
                                    //       fontSize: 16.0);
                                    //   _hideOverlayProgress();
                                    // }
                                  },
                                  text: 'Submit',
                                  width: 100,
                                  height: 40,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  double _getClosingBalance() {
    return widget.shop.closingBalance + -_totalAmountCollected;
  }

  List<PaymentMode> _paymentModes = [];

  TextEditingController _cashAmountController = TextEditingController();
  TextEditingController _chequeAmountController = TextEditingController();
  TextEditingController _gpayAmountController = TextEditingController();
  TextEditingController _chequeNumberController = TextEditingController();
  PlatformFile? _chequePhoto;

  Widget _paymentDetails() {
    return Container(
      width: 400,
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('Cash', () {
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
                visible: _paymentModes.contains(PaymentMode.CASH),
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
          if (_paymentModes.contains(PaymentMode.CASH)) SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('Cheque', () {
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
                  visible: _paymentModes.contains(PaymentMode.CHEQUE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      UploadButton(
                        width: 240,
                        onSelectPressed: () async {
                          _chequePhoto = await showImagePicker(true);
                          setState(() {});
                        },
                        onClearPressed: () {
                          setState(() {
                            _chequePhoto = null;
                          });
                        },
                        label: 'Cheque Photo',
                        fileName:
                            _chequePhoto == null ? null : _chequePhoto!.name,
                      ),
                      SizedBox(height: 10),
                      CustomInputField(
                        controller: _chequeNumberController,
                        keyboardType: TextInputType.number,
                        hint: 'Cheque No.',
                        width: 120,
                        onChanged: () {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 5),
                      CustomInputField(
                        controller: _chequeAmountController,
                        keyboardType: TextInputType.number,
                        hint: 'Amount',
                        width: 120,
                        onChanged: () {
                          _updateCashTotal();
                        },
                      ),
                    ],
                  )),
            ],
          ),
          if (_paymentModes.contains(PaymentMode.CHEQUE)) SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkBox('GPay', () {
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
                visible: _paymentModes.contains(PaymentMode.GPAY),
                child: CustomInputField(
                  controller: _gpayAmountController,
                  keyboardType: TextInputType.number,
                  hint: 'Amount',
                  width: 120,
                  onChanged: () {
                    _updateCashTotal();
                  },
                ),
              ),
            ],
          ),
          if (_paymentModes.contains(PaymentMode.GPAY)) SizedBox(height: 20),
          Divider(
            color: grayDark,
          ),
          if (widget.shop.shopType == ShopType.PARENT)
            _textRow('Total Amount Collected',
                '${_totalAmountCollected.toStringAsFixed(2)} Rs.', true, 0),
          if (widget.shop.shopType == ShopType.PARENT)
            _textRow('Closing Balance after payment',
                '${_getClosingBalance().round().toString()} Rs.', false, 0),
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

  void _showOverlayProgress() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideOverlayProgress() {
    setState(() {
      _isLoading = false;
    });
  }
}
