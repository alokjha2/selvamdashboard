import 'package:data_table_2/data_table_2.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/paginated_data_table_2.dart';

class ShopDataTable extends StatefulWidget {
  final Widget? actionButton;
  final double? minWidth;
  final List<Shop> shopsList;
  final ChildStateUpdateController? stateUpdater;
  final Function? onEditPressed;
  final Function? onAccountPressed;
  final Function? onDeletePressed;
  final Function? onRowPressed;
  final Function? onPaymentAdd;
  final Function? onNotespressed;
  final Function? onPaymentHistoryPressed;
  final Function? onAddDirectSalePressed;
  final Function? onDirectSaleHistoryPressed;
  final Function? onAddDiscountPressed;
  final Function? onAddAdditionalAmountPressed;
  final Function? onChickenReturnPressed;

  ShopDataTable({
    Key? key,
    this.actionButton,
    this.minWidth,
    required this.shopsList,
    this.stateUpdater,
    this.onEditPressed,
    this.onAccountPressed,
    this.onDeletePressed,
    this.onPaymentAdd,
    this.onPaymentHistoryPressed,
    this.onNotespressed,
    this.onAddDirectSalePressed,
    this.onDirectSaleHistoryPressed,
    this.onRowPressed,
    this.onAddDiscountPressed,
    this.onAddAdditionalAmountPressed,
    this.onChickenReturnPressed,
  }) : super(key: key);

  @override
  _ShopDataTableState createState() => _ShopDataTableState();
}

class _ShopDataTableState extends State<ShopDataTable> {
  late ShopDataSource _dataSource;
  int _rowIndex = 0;
  late int _rowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late List<Shop> _filteredList;
  final TextEditingController _searchController = TextEditingController();

  List<TripRoute> _routeList = [];
  TripRoute? _selectedRoute;
  final _dropDownDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(6.0),
      ),
      borderSide: BorderSide(color: primaryBorder, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(6.0),
      ),
      borderSide: BorderSide(color: primaryBorder, width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
    ),
    contentPadding: EdgeInsets.all(10),
  );

  @override
  void initState() {
    _filteredList = widget.shopsList;
    _dataSource = _getDataSource(_filteredList);
    _rowsPerPage = _filteredList.length;
    widget.stateUpdater!.updateState = () {
      setState(() {
        _filteredList = widget.shopsList;
        _dataSource = _getDataSource(_filteredList);
        _rowsPerPage = _filteredList.length;
      });
    };
    super.initState();
    RouteDatabase().getAllRoutes().then((value) {
      if (mounted) {
        setState(() {
          _routeList.addAll(value);
        });
      }
    });
  }

  ShopDataSource _getDataSource(List<Shop> shopsList) {
    return ShopDataSource(
      context: context,
      shopsList: shopsList,
      onAccountPressed: widget.onAccountPressed,
      onDeletePressed: widget.onDeletePressed,
      onEditPressed: widget.onEditPressed,
      onPaymentAdd: widget.onPaymentAdd,
      onPaymentHistoryPressed: widget.onPaymentHistoryPressed,
      onNotespressed: widget.onNotespressed,
      onAddDirectSalePressed: widget.onAddDirectSalePressed,
      onDirectSaleHistoryPressed: widget.onDirectSaleHistoryPressed,
      onRowPressed: widget.onRowPressed,
      onAddDiscountPressed: widget.onAddDiscountPressed,
      onAddAditionalAmountPressed: widget.onAddAdditionalAmountPressed,
      onChickenReturnPressed: widget.onChickenReturnPressed,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void sort<T>(
    Comparable<T> Function(Shop d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }

  ScrollController _scrollBar = ScrollController();
  PaginatorController _paginatorController = PaginatorController();
  @override
  Widget build(BuildContext context) {
    return 
    // Text("data");
    
    PaginatedDataTable2(
      scrollController: _scrollBar,
      controller: _paginatorController,
      horizontalMargin: 10,
      columnSpacing: 20,
      showCheckboxColumn: false,
      wrapInCard: false,
      // autoRowsToHeight: true,
      availableRowsPerPage: [20, 30, 50, 100, 500],
      rowsPerPage: 30,
      headingRowHeight: 50,
      smRatio: 1,
      lmRatio: 3,

      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomSearchInputField(
            hint: 'Search Shop Name',
            controller: _searchController,
            onClear: () {
              _clearSearch();
            },
            onChanged: (String value) {
              value = value.toLowerCase();
              if (value.isEmpty) {
                _clearSearch();
              }
              setState(() {
                _selectedRoute = null;
                _filteredList = widget.shopsList
                    .where((d) => d.shopName.toLowerCase().contains(value))
                    .toList();

                _rowIndex = 0;
                _dataSource = _getDataSource(_filteredList);
              });
              _paginatorController.goToFirstPage();
            },
          ),
          _labeledWidget(
              'Area',
              DropdownButton<TripRoute>(
                style: Theme.of(context).textTheme.bodyText2,
                value: _selectedRoute,
                isDense: true,
                isExpanded: true,
                hint: Text('All Area'),
                items: [
                  DropdownMenuItem<TripRoute>(
                    child: Text('All Areas'),
                    onTap: () {
                      _selectedRoute = null;
                      _clearSearch();
                    },
                  ),
                  ..._routeList.map((TripRoute value) {
                    return DropdownMenuItem<TripRoute>(
                      value: value,
                      child: Text(value.routeName + ' - ' + value.routeNumber),
                    );
                  }).toList()
                ],
                onChanged: (newValue) {
                  _selectedRoute = newValue;
                  if (newValue != null) {
                    setState(() {
                      _filteredList = widget.shopsList
                          .where((d) => d.routeIDs.contains(newValue.docID))
                          .toList();

                      _rowIndex = 0;
                      _dataSource = _getDataSource(_filteredList);
                    });
                    _paginatorController.goToFirstPage();
                  }
                },
              )),
          Container(child: widget.actionButton)
        ],
      ),
      minWidth: widget.minWidth ?? 600,
      // dataRowHeight: 60,
      fit: FlexFit.tight,
      border: TableBorder(
          top: BorderSide(color: primaryBorder),
          bottom: BorderSide(color: primaryBorder),
          left: BorderSide(color: primaryBorder),
          right: BorderSide(color: primaryBorder),
          verticalInside: BorderSide(color: transparent),
          horizontalInside: BorderSide(color: primaryBorder, width: 1)),
      onRowsPerPageChanged: (value) {
        setState(() {
          _rowsPerPage = value!;
        });
      },
      initialFirstRowIndex: _rowIndex,
      onPageChanged: (rowIndex) {
        setState(() {
          _rowIndex = rowIndex;
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn2(
          size: ColumnSize.S,
          label: _headerText(text: 'Sl.No'),
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.slNo, columnIndex, ascending),
        ),
        DataColumn2(
          size: ColumnSize.L,
          label: _headerText(text: 'Shop Name'),
          onSort: (columnIndex, ascending) =>
              sort<String>((d) => d.shopName, columnIndex, ascending),
        ),
        // DataColumn2(
        //   size: ColumnSize.L,
        //   label: _headerText(text: 'Phone'),
        // ),
        // DataColumn2(
        //   size: ColumnSize.M,
        //   label: _headerText(text: 'Address'),
        // ),
        // DataColumn2(
        //   size: ColumnSize.M,
        //   label: _headerText(text: 'Region'),
        // ),
        DataColumn2(
          size: ColumnSize.L,
          label: _headerText(text: 'Closing Balance'),
          onSort: (columnIndex, ascending) =>
              sort<num>((d) => d.closingBalance, columnIndex, ascending),
        ),
        DataColumn2(
          size: ColumnSize.S,
          label: _headerText(text: 'Actions'),
        ),
      ],
      empty: Center(
          child: Text(
        'No data found!',
        style: Theme.of(context).textTheme.headline2!.copyWith(color: gray),
      )),
      source: _dataSource,
    );
  }

  Widget _labeledWidget(String label, Widget child) {
    return Container(
      width: 240,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.subtitle1),
          Container(
            width: 180,
            child: InputDecorator(
              decoration: _dropDownDecoration,
              child: DropdownButtonHideUnderline(
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.text = '';
      _filteredList = widget.shopsList;
      _dataSource = _getDataSource(_filteredList);
    });
    _paginatorController.goToFirstPage();
  }

  Widget _headerText({required String text}) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .subtitle2!
          .copyWith(color: secondaryTextDark),
    );
  }
}

class ShopDataSource extends DataTableSource {
  final BuildContext context;
  late List<Shop> shopsList;
  Function? onEditPressed;
  Function? onAccountPressed;
  Function? onDeletePressed;
  Function? onRowPressed;
  Function? onPaymentAdd;
  Function? onNotespressed;
  Function? onPaymentHistoryPressed;
  Function? onAddDirectSalePressed;
  Function? onDirectSaleHistoryPressed;
  Function? onAddDiscountPressed;
  Function? onAddAditionalAmountPressed;
  Function? onChickenReturnPressed;

  ShopDataSource.empty(this.context) {
    shopsList = [];
  }

  ShopDataSource({
    required this.context,
    required List<Shop> shopsList,
    Function? onEditPressed,
    Function? onAccountPressed,
    Function? onPaymentAdd,
    Function? onDeletePressed,
    Function? onRowPressed,
    Function? onNotespressed,
    Function? onPaymentHistoryPressed,
    Function? onAddDirectSalePressed,
    Function? onDirectSaleHistoryPressed,
    Function? onAddDiscountPressed,
    Function? onAddAditionalAmountPressed,
    Function? onChickenReturnPressed,
  }) {
    this.shopsList = shopsList;
    this.onEditPressed = onEditPressed;
    this.onAccountPressed = onAccountPressed;
    this.onDeletePressed = onDeletePressed;
    this.onRowPressed = onRowPressed;
    this.onPaymentAdd = onPaymentAdd;
    this.onNotespressed = onNotespressed;
    this.onPaymentHistoryPressed = onPaymentHistoryPressed;
    this.onAddDirectSalePressed = onAddDirectSalePressed;
    this.onDirectSaleHistoryPressed = onDirectSaleHistoryPressed;
    this.onAddDiscountPressed = onAddDiscountPressed;
    this.onAddAditionalAmountPressed = onAddAditionalAmountPressed;
    this.onChickenReturnPressed = onChickenReturnPressed;
  }
  void sort<T>(Comparable<T> Function(Shop d) getField, bool ascending) {
    shopsList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow2 getRow(int index) {
    assert(index >= 0);
    if (index >= shopsList.length) throw 'index > _desserts.length';
    final shop = shopsList[index];

    double height = 50;
    if (shop.shopName.length > 30) {
      height += 25;
    }
    return 
    
    DataRow2.byIndex(
      index: index,
      // specificRowHeight: height,
      // onSelectChanged: (bool? val) {
      //   this.onRowPressed?.call(shop);
      // },
      cells: [
        DataCell(_bodyText(text: shop.slNo.toString())),
        DataCell(_bodyText(text: shop.shopName)),
        // DataCell(_bodyText(text: shop.phoneNumber)),
        // DataCell(_bodyText(text: shop.address)),
        // DataCell(_bodyText(text: shop.regionName)),
        DataCell(
            _bodyText(text: '${shop.closingBalance.toStringAsFixed(2)} Rs.')),
        DataCell(_actionButtons(shop)),
      ],
    );
  }

  @override
  int get rowCount => shopsList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  Widget _bodyText({String? text, Color? color}) {
    return Text(
      text ?? '',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: color ?? primaryTextDark, height: 1.05),
    );
  }

  Widget _actionButtons(Shop shop) {
    return Row(
      children: [
        CustomIconButton(
          icon: PopupMenuButton<String>(
            onSelected: (String val) {
              if (val == 'detail') {
                this.onRowPressed?.call(shop);
              } else if (val == 'add_payment') {
                this.onPaymentAdd?.call(shop);
              } else if (val == 'payment_history') {
                this.onPaymentHistoryPressed?.call(shop);
              } else if (val == 'delete') {
                this.onDeletePressed?.call(shop);
              } else if (val == 'edit') {
                this.onEditPressed?.call(shop);
              } else if (val == 'notes') {
                this.onNotespressed?.call(shop);
              } else if (val == 'add_direct_sales') {
                this.onAddDirectSalePressed?.call(shop);
              } else if (val == 'direct_sales_history') {
                this.onDirectSaleHistoryPressed?.call(shop);
              } else if (val == 'add_discount') {
                this.onAddDiscountPressed?.call(shop);
              } else if (val == 'add_amount') {
                this.onAddAditionalAmountPressed?.call(shop);
              } else if (val == 'chicken_return') {
                this.onChickenReturnPressed?.call(shop);
              }
            },
            child: Icon(Icons.more_vert_rounded),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                child: Text('Store Direct Sale'),
                value: 'add_direct_sales',
              ),
              if (shop.shopType == ShopType.PARENT)
                PopupMenuItem<String>(
                  child: Text('Add Discount'),
                  value: 'add_discount',
                ),
              if (shop.shopType == ShopType.PARENT)
                PopupMenuItem<String>(
                  child: Text('Add Additional Amount'),
                  value: 'add_amount',
                ),
              if (shop.shopType == ShopType.PARENT)
                PopupMenuItem<String>(
                  child: Text('Add Payment'),
                  value: 'add_payment',
                ),
              PopupMenuItem<String>(
                child: Text('Return Chicken'),
                value: 'chicken_return',
              ),
              PopupMenuItem<String>(
                child: Text('Order & Payments History'),
                value: 'direct_sales_history',
              ),
              PopupMenuItem<String>(
                child: Text('View Details'),
                value: 'detail',
              ),
              PopupMenuItem<String>(
                child: Text('Notes'),
                value: 'notes',
              ),
              // PopupMenuItem<String>(
              //   child: Text('Payment History'),
              //   value: 'payment_history',
              // ),
              PopupMenuItem<String>(
                child: Text('Edit'),
                value: 'edit',
              ),
              // PopupMenuItem<String>(
              //   child: Text('Delete'),
              //   value: 'delete',
              // ),
            ],
          ),
          onPressed: () {},
        )
      ],
    );
  }
}
