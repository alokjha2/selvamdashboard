import 'package:flutter/services.dart';
import 'package:selvam_broilers/models/additional_amount.dart';
import 'package:selvam_broilers/models/discount.dart';
import 'package:selvam_broilers/models/shop.dart';

import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';

class AddAdditionalAmountDialog extends StatefulWidget {
  final Shop shop;
  const AddAdditionalAmountDialog({Key? key, required this.shop})
      : super(key: key);
  @override
  _AddAdditionalAmountDialogState createState() =>
      _AddAdditionalAmountDialogState();
}

class _AddAdditionalAmountDialogState extends State<AddAdditionalAmountDialog> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var focusNode = FocusNode();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.shop.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Container(
              width: 340,
              // height: 500,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Add Amount to ${widget.shop.shopName}',
                      style: Theme.of(context).textTheme.headline2!,
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Amount (Rs.)',
                      controller: _amountController,
                      validator: (value) =>
                          value!.length < 1 ? 'Enter discount' : null,
                      textInputFormatter: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Description',
                      controller: _notesController,
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButton(
                              width: 100,
                              height: 36,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              text: 'Close'),
                          CustomButton(
                              width: 100,
                              height: 36,
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _showOverlayProgress();

                                AdditionalAmount amount = AdditionalAmount(
                                    addedTime: DateTime.now(),
                                    amount: double.tryParse(
                                            _amountController.text) ??
                                        0,
                                    description: _notesController.text,
                                    shopID: widget.shop.docID!);
                                bool res = await ShopDatabase()
                                    .addAdditionalAmount(
                                        shopID: widget.shop.docID!,
                                        amount: amount);
                                _hideOverlayProgress();
                                if (res) {
                                  showToast(message: 'Amount added.');
                                  Navigator.pop(context);
                                } else {
                                  showToast(
                                      message:
                                          'Unable to add amount. Try again.');
                                }
                              },
                              text: 'Update'),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOverlayProgress() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
  }

  void _hideOverlayProgress() {
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }
}
