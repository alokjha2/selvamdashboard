import 'package:flutter/material.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/sale_order.dart';
import 'package:selvam_broilers/services/sale_db.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/utils/colors.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/sale/create_sale_order.dart';
import 'package:selvam_broilers/widgets/sale/sale_order_data_table.dart';

class SaleRequestListWidget extends StatefulWidget {
  final List<SaleOrder> salesList;
  final ChildStateUpdateController controller;
  final List<TripRoute> routeList;

  const SaleRequestListWidget({
    Key? key,
    required this.salesList,
    required this.controller,
    required this.routeList,
  }) : super(key: key);

  @override
  _SaleRequestListWidgetState createState() => _SaleRequestListWidgetState();
}

class _SaleRequestListWidgetState extends State<SaleRequestListWidget> {
  SaleOrderDatabase _saleDB = SaleOrderDatabase();
  ChildStateUpdateController _childStateUpdateController =
      ChildStateUpdateController();

  @override
  void initState() {
    super.initState();
    widget.controller.updateState = () {
      if (mounted) {
        setState(() {});
        _childStateUpdateController.updateState?.call();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SaleOrderDataTable(
        isOrderRequest: true,
        actionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sale Order Requests',
              style: Theme.of(context).textTheme.headline3,
            )
          ],
        ),
        saleList: widget.salesList,
        stateUpdater: _childStateUpdateController,
        onRowPressed: (SaleOrder sale) async {
          _showEditDialog(context, sale);
        },
        onDeletePressed: (SaleOrder sale) async {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Confirmation'),
              content: Text('Sure want to delete sales ${sale.orderID}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    bool res = await _saleDB.deleteSaleOrder(data: sale);
                    if (res) {
                      Navigator.pop(context);
                      showToast(message: 'Sale deleted!');
                    } else {
                      showToast(message: 'Operation Failed!', color: red);
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, SaleOrder sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: CreateSaleOrderWidget(
            selectedRoute: null,
            orderDate: sale.orderDate,
            saleOrder: sale,
            routeList: widget.routeList,
          ),
        );
      },
    );
  }
}
