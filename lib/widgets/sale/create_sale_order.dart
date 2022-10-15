import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import '../../models/sale_order.dart';
import 'package:selvam_broilers/services/sale_db.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';

class CreateSaleOrderWidget extends StatefulWidget {
  final List<Shop>? shopList;
  final List<TripRoute>? routeList;
  final String orderDate;
  final TripRoute? selectedRoute;
  final SaleOrder? saleOrder;

  const CreateSaleOrderWidget({
    Key? key,
    required this.orderDate,
    this.routeList,
    this.selectedRoute,
    this.shopList,
    this.saleOrder,
  }) : super(key: key);

  @override
  _CreateSaleOrderWidgetState createState() => _CreateSaleOrderWidgetState();
}

class _CreateSaleOrderWidgetState extends State<CreateSaleOrderWidget> {
  bool _isLoading = false;
  SaleOrderDatabase _saleDB = SaleOrderDatabase();
  TextEditingController _regularCount = TextEditingController();
  TextEditingController _regularKG = TextEditingController();
  TextEditingController _smallCount = TextEditingController();
  TextEditingController _smallKG = TextEditingController();
  TextEditingController _smallWeightRef = TextEditingController();
  TextEditingController _saleID = TextEditingController();
  TripRoute? _selectedRoute;

  String _errorMessage = '';
  Shop? _selectedShop;
  bool _isEditMode = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.saleOrder != null;
    if (_isEditMode) {
      _regularCount.text = widget.saleOrder!.regularInCount.toString();
      _regularKG.text = widget.saleOrder!.regularInKG.toString();
      _smallCount.text = widget.saleOrder!.smallInCount.toString();
      _smallKG.text = widget.saleOrder!.smallInKG.toString();
      _saleID.text = widget.saleOrder!.orderID;
      _smallWeightRef.text = widget.saleOrder!.smallWeightRef.toString();
    }

    _getData();
  }

  void _getData() {
    if (!_isEditMode)
      _saleDB.getSaleOrderID().then((value) {
        _saleID.text = value;
      });
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_isEditMode ? 'Update' : 'Create'} Sales Order',
                      style: Theme.of(context).textTheme.headline2!,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            CustomInputField(
                                readOnly: true,
                                width: 340,
                                hint: 'Order ID',
                                controller: _saleID,
                                validator: (value) => value!.length < 3
                                    ? 'Enter valid Name'
                                    : null),
                            SizedBox(height: 10),
                            CustomInputField(
                              readOnly: true,
                              width: 340,
                              hint: 'Order Date',
                              controller:
                                  TextEditingController(text: widget.orderDate),
                            ),
                            SizedBox(height: 10),
                            if (_isEditMode)
                              CustomInputField(
                                readOnly: true,
                                width: 340,
                                hint: 'Shop Name',
                                controller: TextEditingController(
                                    text: widget.saleOrder!.shopInfo!.shopName),
                              ),
                            if (!_isEditMode)
                              _labeledWidgetBorderLess(
                                'Shop',
                                Autocomplete<Shop>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    return widget.shopList!
                                        .where((Shop county) => county.shopName
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .toLowerCase()))
                                        .toList();
                                  },
                                  displayStringForOption: (Shop option) =>
                                      option.shopName,
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          fieldTextEditingController,
                                      FocusNode fieldFocusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return CustomInputField(
                                      height: 50,
                                      // width: 100,
                                      keyboardType: TextInputType.name,
                                      controller: (() {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          fieldTextEditingController.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset:
                                                          fieldTextEditingController
                                                              .text.length));
                                        });
                                        return fieldTextEditingController;
                                      })(),
                                      focusNode: fieldFocusNode,
                                      hint: 'Search Shop',
                                      onSubmitted: (String text) {
                                        setState(() {
                                          _selectedShop = null;
                                        });
                                      },
                                    );
                                  },
                                  onSelected: (Shop selection) {
                                    setState(() {
                                      _selectedShop = selection;
                                    });
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<Shop> onSelected,
                                      Iterable<Shop> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        child: Container(
                                          height: 300,
                                          width: 220,
                                          child: ListView.builder(
                                            padding: EdgeInsets.all(10.0),
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final Shop option =
                                                  options.elementAt(index);

                                              return GestureDetector(
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                                child: ListTile(
                                                  title: Text(option.shopName,
                                                      maxLines: 5,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            _entryField(
                                'Regular', _regularCount, _regularKG, () {}),
                            SizedBox(height: 5),
                            _entryField('Small', _smallCount, _smallKG, () {
                              _smallKG.text =
                                  ((double.tryParse(_smallWeightRef.text) ??
                                              0) *
                                          (double.tryParse(_smallCount.text) ??
                                              0))
                                      .toStringAsFixed(2);
                            }),
                            SizedBox(height: 5),
                            _labeledWidgetBorderLess(
                              'Weight per chicken (Small)',
                              CustomInputField(
                                hint: 'Weight (KG)',
                                controller: _smallWeightRef,
                                keyboardType: TextInputType.number,
                                onChanged: () {
                                  _smallKG.text = ((double.tryParse(
                                                  _smallWeightRef.text) ??
                                              0) *
                                          (double.tryParse(_smallCount.text) ??
                                              0))
                                      .toStringAsFixed(2);
                                },
                              ),
                            ),
                            if (widget.selectedRoute == null)
                              SizedBox(height: 10),
                            if (widget.selectedRoute == null)
                              _labeledWidget(
                                'Area',
                                DropdownButton<TripRoute>(
                                  underline: SizedBox(),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  value: _selectedRoute,
                                  isDense: true,
                                  isExpanded: true,
                                  hint: Text('Select Area'),
                                  items: [
                                    DropdownMenuItem<TripRoute>(
                                      child: Text('Select Area'),
                                      onTap: () {
                                        setState(() {
                                          // _routeID = '';
                                          _selectedRoute = null;
                                        });
                                      },
                                    ),
                                    ...widget.routeList!.map((TripRoute value) {
                                      return DropdownMenuItem<TripRoute>(
                                        value: value,
                                        child: Text(value.routeName),
                                      );
                                    }).toList()
                                  ],
                                  onChanged: (newValue) {
                                    if (newValue == null) return;

                                    setState(() {
                                      _selectedRoute = newValue;
                                    });
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            Text(
                              _errorMessage,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                  width: 100,
                                  height: 36,
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

                                  if (!_isEditMode && _selectedShop == null) {
                                    setState(() {
                                      _errorMessage = 'Please select a shop.';
                                    });
                                    return;
                                  }
                                  if (_regularKG.text.isEmpty &&
                                      _smallKG.text.isEmpty) {
                                    setState(() {
                                      _errorMessage =
                                          'Enter at least one entry!';
                                    });
                                    return;
                                  }

                                  if (widget.selectedRoute == null &&
                                      _selectedRoute == null) {
                                    setState(() {
                                      _errorMessage = 'Please Select area.';
                                    });
                                    return;
                                  }

                                  setState(() {
                                    _errorMessage = '';
                                  });
                                  _showOverlayProgress();

                                  bool res = false;
                                  if (_isEditMode) {
                                    final order = widget.saleOrder!;
                                    if (widget.selectedRoute == null) {
                                      //add selected route
                                      order.routeID = _selectedRoute!.docID!;
                                    }
                                    order.regularInCount = double.parse(
                                        _regularCount.text.isEmpty
                                            ? '0'
                                            : _regularCount.text.trim());
                                    order.regularInKG = double.parse(
                                        _regularKG.text.isEmpty
                                            ? '0'
                                            : _regularKG.text.trim());
                                    order.smallInCount = double.parse(
                                        _smallCount.text.isEmpty
                                            ? '0'
                                            : _smallCount.text.trim());
                                    order.smallInKG = double.parse(
                                        _smallKG.text.isEmpty
                                            ? '0'
                                            : _smallKG.text.trim());
                                    res = await _saleDB.updateSaleOrder(
                                        data: order);
                                  } else {
                                    final order = SaleOrder(
                                        orderType: OrderType.DELIVERY_SALES,
                                        orderPlacedBy: OrderBy.ADMIN,
                                        orderID: _saleID.text,
                                        shopID: _selectedShop!.docID!,
                                        routeID: widget.selectedRoute!.docID!,
                                        regularInCount: double.parse(
                                            _regularCount.text.isEmpty
                                                ? '0'
                                                : _regularCount.text.trim()),
                                        regularInKG: double.parse(
                                            _regularKG.text.isEmpty
                                                ? '0'
                                                : _regularKG.text.trim()),
                                        smallInCount: double.parse(
                                            _smallCount.text.isEmpty
                                                ? '0'
                                                : _smallCount.text.trim()),
                                        smallInKG: double.parse(_smallKG.text.isEmpty
                                            ? '0'
                                            : _smallKG.text.trim()),
                                        smallWeightRef: double.tryParse(
                                                _smallWeightRef.text.trim()) ??
                                            0,
                                        createdTime: DateTime.now(),
                                        orderDate: widget.orderDate,
                                        orderStatus: OrderStatus.PENDING);
                                    res =
                                        await _saleDB.addSaleOrder(data: order);
                                  }

                                  if (res) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Order ${_isEditMode ? 'Updated' : 'Created'}',
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
                                        msg:
                                            "Unable to ${_isEditMode ? 'update' : 'create'}. Try again.",
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
                                },
                                text: _isEditMode ? 'Update' : 'Create',
                                width: 100,
                                height: 36,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entryField(String label, TextEditingController count,
      TextEditingController kg, Function onCountChanged) {
    return Container(
      width: 340,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyText2),
          Container(
            width: 220,
            child: Row(
              children: [
                Flexible(
                  child: CustomInputField(
                    hint: 'Weight (KG)',
                    controller: kg,
                    keyboardType: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: CustomInputField(
                    hint: 'Count',
                    controller: count,
                    keyboardType: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: onCountChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledWidget(String label, Widget child) {
    return Container(
      width: 340,
      height: 46,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(label, style: Theme.of(context).textTheme.subtitle1)),
          Container(
            width: 220,
            child: InputDecorator(
              decoration: InputDecoration(
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
              ),
              child: DropdownButtonHideUnderline(
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledWidgetBorderLess(String label, Widget child) {
    return Container(
      width: 340,
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(label, style: Theme.of(context).textTheme.subtitle1)),
          Container(width: 220, child: child),
        ],
      ),
    );
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
