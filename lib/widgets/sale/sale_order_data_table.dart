import 'package:data_table_2/data_table_2.dart';
import 'package:selvam_broilers/utils/flags.dart';
import '../../models/sale_order.dart';
import 'package:selvam_broilers/utils/child_callback_controller.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/paginated_data_table_2.dart';

import '../custom_button.dart';

class SaleOrderDataTable extends StatefulWidget {
  final Widget? actionButton;
  final double? minWidth;
  final List<SaleOrder> saleList;
  final ChildStateUpdateController stateUpdater;
  final Function? onEditPressed;
  final Function? onDeletePressed;
  final Function? onRowPressed;
  final Function? onOrderCompletePressed;
  final bool? isPastDateSelected;
  final bool? isOrderRequest;

  SaleOrderDataTable(
      {Key? key,
      this.actionButton,
      this.minWidth,
      required this.saleList,
      this.isPastDateSelected,
      this.isOrderRequest,
      required this.stateUpdater,
      this.onEditPressed,
      this.onDeletePressed,
      this.onOrderCompletePressed,
      this.onRowPressed})
      : super(key: key);

  @override
  _SaleOrderDataTableState createState() => _SaleOrderDataTableState();
}

class _SaleOrderDataTableState extends State<SaleOrderDataTable> {
  late OrderDataSource _dataSource;
  int _rowIndex = 0;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  late List<SaleOrder> _filteredList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _filteredList = widget.saleList;
    _dataSource = _getDataSource(_filteredList);
    widget.stateUpdater.updateState = () {
      if (mounted)
        setState(() {
          _filteredList = widget.saleList;
          _dataSource = _getDataSource(_filteredList);
        });
    };
    super.initState();
  }

  OrderDataSource _getDataSource(List<SaleOrder> saleList) {
    return OrderDataSource(
        context: context,
        saleList: saleList,
        onDeletePressed: widget.onDeletePressed,
        onEditPressed: widget.onEditPressed,
        isPastDateSelected: widget.isPastDateSelected ?? false,
        isOrderRequest: (widget.isOrderRequest ?? false),
        onOrderCompletePressed: widget.onOrderCompletePressed,
        onRowPressed: widget.onRowPressed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void sort<T>(
    Comparable<T> Function(SaleOrder d) getField,
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
      horizontalMargin: 20,
      columnSpacing: 20,
      showCheckboxColumn: false,
      wrapInCard: false,
      availableRowsPerPage: [widget.saleList.length + 1],
      rowsPerPage: widget.saleList.length + 1,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!(widget.isOrderRequest ?? false))
            CustomSearchInputField(
              width: 240,
              hint: 'Search Shop',
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
                  _filteredList = widget.saleList
                      .where((d) =>
                          d.shopInfo!.shopName.toLowerCase().contains(value))
                      .toList();

                  _rowIndex = 0;
                  _dataSource = _getDataSource(_filteredList);
                });
                _paginatorController.goToFirstPage();
              },
            ),
          Container(child: widget.actionButton)
        ],
      ),
      minWidth: widget.minWidth ?? 600,
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
          size: ColumnSize.S,
          label: _headerText(text: 'Order ID'),
        ),
        DataColumn2(
          size: ColumnSize.L,
          label: _headerText(text: 'Shop Name'),
          onSort: (columnIndex, ascending) => sort<String>(
              (d) => d.shopInfo?.shopName ?? '[DELETED]',
              columnIndex,
              ascending),
        ),
        DataColumn2(
          size: ColumnSize.S,
          label: _headerText(text: 'Total KGs'),
        ),
        DataColumn2(
          size: ColumnSize.S,
          label: _headerText(text: 'Order Status'),
        ),
        DataColumn2(
          size: ColumnSize.S,
          label: _headerText(text: 'Actions'),
        ),
      ],
      empty: Center(
          child: Text(
        'No orders found!',
        style: Theme.of(context).textTheme.headline2!.copyWith(color: gray),
      )),
      source: _dataSource,
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.text = '';
      _filteredList = widget.saleList;
      _dataSource = _getDataSource(_filteredList);
    });
    _paginatorController.goToFirstPage();
  }

  Widget _headerText({required String text}) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .subtitle2!
          .copyWith(color: secondaryTextDark),
    );
  }
}

class OrderDataSource extends DataTableSource {
  final BuildContext context;
  List<SaleOrder> saleList = [];
  Function? onEditPressed;
  Function? onDeletePressed;
  Function? onRowPressed;
  Function? onOrderCompletePressed;
  late bool isPastDateSelected;
  late bool isOrderRequest;

  OrderDataSource.empty(this.context) {
    saleList = [];
    isPastDateSelected = false;
    isOrderRequest = false;
  }

  OrderDataSource({
    required this.context,
    required List<SaleOrder> saleList,
    Function? onEditPressed,
    Function? onDeletePressed,
    Function? onRowPressed,
    Function? onOrderCompletePressed,
    required bool isOrderRequest,
    required bool isPastDateSelected,
  }) {
    this.saleList = saleList;
    this.onEditPressed = onEditPressed;
    this.onDeletePressed = onDeletePressed;
    this.onRowPressed = onRowPressed;
    this.onOrderCompletePressed = onOrderCompletePressed;
    this.isOrderRequest = isOrderRequest;
    this.isPastDateSelected = isPastDateSelected;
  }

  void sort<T>(Comparable<T> Function(SaleOrder d) getField, bool ascending) {
    saleList.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= saleList.length) throw 'index > _desserts.length';
    final sale = saleList[index];

    return DataRow.byIndex(
      index: index,
      onSelectChanged: (bool? val) {
        this.onRowPressed?.call(sale);
      },
      cells: [
        DataCell(_bodyText(text: sale.slNo.toString())),
        DataCell(_bodyText(text: sale.orderID)),
        DataCell(_bodyText(text: sale.shopInfo?.shopName ?? '[DELETED]')),
        DataCell(_bodyText(text: '${sale.smallInKG + sale.regularInKG}')),
        DataCell(_bodyText(
            text: (sale.orderStatus == OrderStatus.COMPLETED)
                ? 'Completed'
                : 'Pending',
            color: (sale.orderStatus == OrderStatus.COMPLETED)
                ? primaryButton
                : yellowDark)),
        DataCell(
          _actionButtons(sale),
        ),
      ],
    );
  }

  @override
  int get rowCount => saleList.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  Widget _bodyText({String? text, Color? color}) {
    return Text(
      text ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: color ?? primaryTextDark),
    );
  }

  Widget _actionButtons(SaleOrder order) {
    return Row(
      children: [
        CustomIconButton(
          icon: PopupMenuButton<String>(
            onSelected: (String val) {
              if (val == 'detail') {
                this.onRowPressed?.call(order);
              } else if (val == 'delete') {
                this.onDeletePressed?.call(order);
              } else if (val == 'edit') {
                this.onEditPressed?.call(order);
              } else if (val == 'complete_order') {
                this.onOrderCompletePressed?.call(order);
              }
            },
            child: Icon(Icons.more_vert_rounded),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (order.orderStatus != OrderStatus.COMPLETED && !isOrderRequest)
                PopupMenuItem<String>(
                  child: Text('Complete This Order'),
                  value: 'complete_order',
                ),
              PopupMenuItem<String>(
                child: Text(isOrderRequest ? 'Assign Route' : 'View Details'),
                value: 'detail',
              ),
              if (order.orderStatus != OrderStatus.COMPLETED &&
                  !isPastDateSelected &&
                  !isOrderRequest)
                PopupMenuItem<String>(
                  child: Text('Edit'),
                  value: 'edit',
                ),
              if (order.orderStatus != OrderStatus.COMPLETED)
                PopupMenuItem<String>(
                  child: Text('Delete'),
                  value: 'delete',
                ),
            ],
          ),
          onPressed: () {},
        )
      ],
    );
  }
}
