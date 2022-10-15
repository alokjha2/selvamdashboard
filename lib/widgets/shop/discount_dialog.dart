import 'package:flutter/services.dart';
import 'package:selvam_broilers/models/discount.dart';
import 'package:selvam_broilers/models/shop.dart';

import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';

class AddDiscountDialog extends StatefulWidget {
  final Shop shop;
  const AddDiscountDialog({Key? key, required this.shop}) : super(key: key);
  @override
  _AddDiscountDialogState createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var focusNode = FocusNode();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _discountController = TextEditingController();

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
                      'Apply discount for ${widget.shop.shopName}',
                      style: Theme.of(context).textTheme.headline2!,
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Discount (Rs.)',
                      controller: _discountController,
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

                                Discount discount = Discount(
                                    addedTime: DateTime.now(),
                                    discount: double.tryParse(
                                            _discountController.text) ??
                                        0,
                                    description: _notesController.text,
                                    shopID: widget.shop.docID!);
                                bool res = await ShopDatabase().addDiscount(
                                    shopID: widget.shop.docID!,
                                    discount: discount);
                                _hideOverlayProgress();
                                if (res) {
                                  showToast(message: 'Discount added.');
                                  Navigator.pop(context);
                                } else {
                                  showToast(
                                      message:
                                          'Unable to add discount. Try again.');
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
