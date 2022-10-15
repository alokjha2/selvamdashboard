import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:selvam_broilers/models/paper_rate.dart';
import 'package:selvam_broilers/models/region.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/database.dart';
import 'package:selvam_broilers/services/region_db.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';

class ShopNotesDialogWidget extends StatefulWidget {
  final Shop shop;
  const ShopNotesDialogWidget({Key? key, required this.shop}) : super(key: key);
  @override
  _ShopNotesDialogWidgetState createState() => _ShopNotesDialogWidgetState();
}

class _ShopNotesDialogWidgetState extends State<ShopNotesDialogWidget> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var focusNode = FocusNode();
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.shop.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
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
                      'Notes for ${widget.shop.shopName}',
                      style: Theme.of(context).textTheme.headline2!,
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Notes',
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
                                widget.shop.notes = _notesController.text;
                                _showOverlayProgress();

                                bool res = await ShopDatabase()
                                    .updateShopNotes(shop: widget.shop);
                                _hideOverlayProgress();
                                if (res) {
                                  showToast(message: 'Notes updated!');
                                  Navigator.pop(context);
                                } else {
                                  showToast(
                                      message:
                                          'Unable to update the notes. Try again.');
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

  Widget _labeledInputField(
      String label, String hint, TextEditingController controller) {
    return Container(
      width: 300,
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            child: Text(label,
                maxLines: 2, style: Theme.of(context).textTheme.subtitle1),
          ),
          Container(
              width: 200,
              child: CustomInputField(hint: hint, controller: controller)),
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
