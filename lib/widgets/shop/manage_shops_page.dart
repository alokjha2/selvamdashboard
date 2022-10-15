import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/pages/home_page.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/shop/chicken_return_widget.dart';
import 'package:selvam_broilers/widgets/shop/create_shop.dart';
import 'package:selvam_broilers/widgets/shop/notes_dialog.dart';
import 'package:selvam_broilers/widgets/shop/shop_data_table.dart';
import 'package:selvam_broilers/widgets/shop/shop_details_widget.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:selvam_broilers/widgets/shop/add_shop_payment.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'add_additional_amount.dart';
import 'discount_dialog.dart';
import 'display_shop_payment.dart';

class ManageShopsWidget extends StatefulWidget {
  @override
  _ManageShopsWidgetState createState() => _ManageShopsWidgetState();
}

class _ManageShopsWidgetState extends State<ManageShopsWidget> {
  ShopDatabase _shopDB = ShopDatabase();
  ChildStateUpdateController _childStateUpdateController =
      ChildStateUpdateController();
  List<Shop> _shopList = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listenShops();
  }

  void _listenShops() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    _shopDB.listenShops().listen((snapshot) {
      _shopList.clear();
      int slNo = 1;
      snapshot.docs.forEach((doc) {
        Shop shop = Shop.fromFirestore(doc);
        shop.slNo = slNo;
        _shopList.add(shop);
        slNo++;
      });
      if (mounted)
        setState(() {
          _isLoading = false;
        });

      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.removed) {
          this._childStateUpdateController.updateState?.call();
        }
      });
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ShopDataTable(
                      actionButton: CustomIconButton(
                          onPressed: () {
                            _showCreateDialog(context);
                          },
                          icon: Icon(Icons.add_box_rounded)),
                      shopsList: _shopList,
                      stateUpdater: _childStateUpdateController,
                      onRowPressed: (Shop shop) async {
                        _showDetailsDialog(this.context, shop);
                      },
                      onPaymentAdd: (Shop shop) async {
                        _showAddPaymentDialog(this.context, shop);
                      },
                      onPaymentHistoryPressed: (Shop shop) async {
                        _showPaymentHistoryDialog(this.context, shop);
                      },
                      onDeletePressed: (Shop shop) async {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('Confirmation'),
                            content: Text(
                                'Sure want to delete shop ${shop.shopName}?\nAll information related to this shop will be deleted including payments.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  bool res =
                                      await _shopDB.deleteShop(shop: shop);
                                  if (res) {
                                    Navigator.pop(context);
                                    showToast(message: 'Shop deleted!');
                                  } else {
                                    showToast(
                                        message: 'Operation Failed!',
                                        color: red);
                                  }
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onEditPressed: (Shop shop) {
                        _showEditDialog(context, shop);
                      },
                      onNotespressed: (Shop shop) {
                        _showNotesDialog(context, shop);
                      },
                      onAddDiscountPressed: (Shop shop) {
                        _showDiscountDialog(context, shop);
                      },
                      onAddAdditionalAmountPressed: (Shop shop) {
                        _showAdditionalPaymentDialog(context, shop);
                      },
                      onDirectSaleHistoryPressed: (Shop shop) {},
                      onAddDirectSalePressed: (Shop shop) {},
                      onChickenReturnPressed: (Shop shop) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ), //this right here
                              child: ChickenReturnWidget(
                                shop: shop,
                              ),
                            );
                          },
                        );
                      },
                    )),
          if (!isPhoneSelected)
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Shops',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: CreateShopWidget(),
        );
      },
    ).then((value) {
      _childStateUpdateController.updateState?.call();
    });
  }

  void _showDetailsDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: ShopDetailsWidget(shop: shop),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: CreateShopWidget(shop: shop),
        );
      },
    );
  }

  void _showAddPaymentDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: PaymentPage(shop: shop),
        );
      },
    );
  }

  void _showPaymentHistoryDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: ShopPaymentWidget(shop: shop),
        );
      },
    );
  }

  void _showNotesDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: ShopNotesDialogWidget(shop: shop),
        );
      },
    );
  }

  void _showDiscountDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: AddDiscountDialog(shop: shop),
        );
      },
    );
  }

  void _showAdditionalPaymentDialog(BuildContext context, Shop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: AddAdditionalAmountDialog(shop: shop),
        );
      },
    );
  }
}
