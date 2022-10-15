import 'package:selvam_broilers/models/direct_sale.dart';
import 'package:selvam_broilers/models/sale_order.dart';

class ChangeRateModel {
  final num newPaperRate;
  final num difference;
  final SaleOrder? saleOrder;
  final DirectSale? directSale;
  ChangeRateModel(
      {required this.newPaperRate,
      required this.difference,
      this.saleOrder,
      this.directSale});
}
