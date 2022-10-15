import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selvam_broilers/models/region.dart';
import 'package:selvam_broilers/models/route.dart';
import 'package:selvam_broilers/models/shop.dart';
import 'package:selvam_broilers/services/region_db.dart';
import 'package:selvam_broilers/services/routes_db.dart';
import 'package:selvam_broilers/services/shops_db.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CreateShopWidget extends StatefulWidget {
  final Shop? shop;

  const CreateShopWidget({Key? key, this.shop}) : super(key: key);
  @override
  _CreateShopWidgetState createState() => _CreateShopWidgetState();
}

class _CreateShopWidgetState extends State<CreateShopWidget> {
  bool _isLoading = false;
  ShopDatabase _shopDB = ShopDatabase();
  RouteDatabase routeDB = RouteDatabase();
  String? lat, log;
  TextEditingController _shopNameController = TextEditingController();
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  TextEditingController _smallDiscountController = TextEditingController();
  TextEditingController _regularDiscountController = TextEditingController();
  TextEditingController _shopSmallDiscountController = TextEditingController();
  TextEditingController _shopRegularDiscountController =
      TextEditingController();
  TextEditingController _shopJanadhaRateController = TextEditingController();
  TextEditingController _shopCreditController = TextEditingController();
  TextEditingController _closingBalanceController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _isoController = TextEditingController(text: '+91');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<TripRoute> _routeList = [];
  List<TripRoute?> _selectedRoutes = [];
  List<Region> _regionList = [];
  Region? _selectedRegion;
  String _errorMessage = '';
  bool _isEditMode = false;
  PlatformFile? _shopPhoto;
  PlatformFile? _ownerPhoto;
  Shop? _selectedParentShop;
  List<Shop> _allParentShops = [];
  List<Shop> _selectedChildShops = [];
  List<Shop> _allChildShops = [];
  ShopType _shopType = ShopType.PARENT;

  @override
  void initState() {
    super.initState();

    _isEditMode = widget.shop != null;

    //adding inputs to fields on edit mode
    if (_isEditMode) {
      _shopNameController.text = widget.shop!.shopName;
      _ownerNameController.text = widget.shop!.ownerName;

      lat = widget.shop!.location?.latitude.toString();
      log = widget.shop!.location?.longitude.toString();

      if (lat == '0') {
        _locationController.text = '';
      } else {
        _locationController.text = 'https://www.google.com/maps/@$lat,$log,14z';
      }

      _addressController.text = widget.shop!.address;
      _phoneController.text = widget.shop!.phoneNumber
          .substring(3, widget.shop!.phoneNumber.length);
      _isoController.text = widget.shop!.phoneNumber.substring(0, 3);

      _smallDiscountController.text =
          widget.shop!.smallDiscountPerKG.toString();
      _regularDiscountController.text =
          widget.shop!.regularDiscountPerKG.toString();
      _shopRegularDiscountController.text =
          widget.shop!.shopRegularDiscountPerKG.toString();
      _shopSmallDiscountController.text =
          widget.shop!.shopSmallDiscountPerKG.toString();
      _closingBalanceController.text = widget.shop!.closingBalance.toString();
      _shopJanadhaRateController.text =
          (widget.shop!.janadhaRate ?? "").toString();
      _shopCreditController.text =
          (widget.shop!.maxAllowedCredit ?? "").toString();

      _shopPhoto = PlatformFile(
          name: widget.shop!.shopPhoto!.fullPath.split('/').last, size: 0);
      _ownerPhoto = PlatformFile(
          name: widget.shop!.ownerPhoto!.fullPath.split('/').last, size: 0);
      _shopType = widget.shop!.shopType;
    }

    _fetchData();
  }

  void _fetchData() async {
    var routeList = await RouteDatabase().getAllRoutes();
    if (_isEditMode) {
      routeList.forEach((route) {
        if (widget.shop!.routeIDs.contains(route.docID)) {
          _selectedRoutes.add(route);
        } else {
          _routeList.add(route);
        }
      });
    } else {
      _routeList = routeList;
    }

    var value = await RegionDatabase().getAllReagion();
    _regionList = value;
    if (_isEditMode) {
      var list = _regionList
          .where((element) => element.regionName == widget.shop!.regionName)
          .toList();
      if (list.isNotEmpty) {
        _selectedRegion = list.first;
      }
    }

    var allShops = await ShopDatabase().getAllShops();

    _allParentShops = allShops
        .where((element) => element.shopType == ShopType.PARENT)
        .toList();

    _allChildShops = allShops
        .where((element) =>
            element.shopType == ShopType.CHILD &&
            (element.parentShop == null || element.parentShop!.isEmpty))
        .toList();

    if (_isEditMode) {
      if (_shopType == ShopType.CHILD) {
        var list = _allParentShops
            .where((element) => element.docID == widget.shop!.parentShop)
            .toList();
        if (list.isNotEmpty) {
          _selectedParentShop = list.first;
        }
      } else if (_shopType == ShopType.PARENT) {
        allShops.forEach((shop) {
          if (widget.shop!.childShops!.contains(shop.docID)) {
            _selectedChildShops.add(shop);
            _allChildShops.remove(shop);
          }
        });
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
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
      child: SingleChildScrollView(
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
                        _isEditMode ? 'Update Shop' : 'Add Shop',
                        style: Theme.of(context).textTheme.headline2!,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CustomInputField(
                                  width: 300,
                                  hint: 'Shop Name',
                                  controller: _shopNameController,
                                  validator: (value) => value!.length < 3
                                      ? 'Enter valid Name'
                                      : null),
                              SizedBox(height: 10),
                              CustomInputField(
                                  width: 300,
                                  hint: 'Address',
                                  controller: _addressController,
                                  validator: (value) => value!.length < 3
                                      ? 'Enter valid Address'
                                      : null),
                              SizedBox(height: 10),
                              CustomPhoneInputField(
                                hint: 'Phone Number',
                                width: 300,
                                isoController: _isoController,
                                numberController: _phoneController,
                                validator: (value) => value!.length != 10
                                    ? 'Enter valid phone number'
                                    : null,
                              ),
                              SizedBox(height: 10),
                              CustomInputField(
                                  width: 300,
                                  hint: 'Owner Name',
                                  controller: _ownerNameController,
                                  validator: (value) => value!.length < 3
                                      ? 'Enter valid Name'
                                      : null),
                              SizedBox(height: 10),
                              CustomInputField(
                                width: 300,
                                hint: 'Location URL',
                                controller: _locationController,
                              ),
                              SizedBox(height: 10),
                              _labeledWidget(
                                'Region',
                                DropdownButton<Region>(
                                  style: Theme.of(context).textTheme.bodyText2,
                                  value: _selectedRegion,
                                  isDense: true,
                                  isExpanded: true,
                                  hint: Text('Select Region'),
                                  items: [
                                    DropdownMenuItem<Region>(
                                      child: Text('Select Region'),
                                      onTap: () {
                                        _selectedRegion = null;
                                      },
                                    ),
                                    ..._regionList.map((Region value) {
                                      return DropdownMenuItem<Region>(
                                        value: value,
                                        child: Text(value.regionName),
                                      );
                                    }).toList()
                                  ],
                                  onChanged: (newValue) {
                                    if (mounted)
                                      setState(() {
                                        _selectedRegion = newValue;
                                      });
                                  },
                                  onTap: () {},
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: 300,
                                // margin: EdgeInsets.only(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Areas',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                        textAlign: TextAlign.left),
                                    SizedBox(height: 5),
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 10,
                                      runSpacing: 5,
                                      children: [
                                        ..._selectedRoutes
                                            .map((item) => Container(
                                                  width: 140,
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: primaryBorder),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          '${item!.routeNumber}-${item.routeName}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color:
                                                                      primaryTextDark),
                                                        ),
                                                      ),
                                                      CustomIconButton(
                                                          width: 20,
                                                          height: 20,
                                                          onPressed: () {
                                                            if (mounted)
                                                              setState(() {
                                                                if (_selectedRoutes
                                                                    .contains(
                                                                        item)) {
                                                                  _routeList
                                                                      .add(
                                                                          item);
                                                                  _selectedRoutes
                                                                      .remove(
                                                                          item);
                                                                }
                                                              });
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                            size: 16,
                                                            color: red,
                                                          )),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                        Visibility(
                                          visible: _routeList.length > 0,
                                          child: Container(
                                            width: 140,
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: primaryBorder),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25))),
                                            child: PopupMenuButton<TripRoute>(
                                              tooltip: 'Add Area',
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Add Area',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                            color:
                                                                primaryTextDark,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                  ),
                                                  Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: primaryDark,
                                                  ),
                                                ],
                                              ),
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      _routeList
                                                          .map((item) =>
                                                              PopupMenuItem<
                                                                  TripRoute>(
                                                                value: item,
                                                                child: Text(
                                                                  '${item.routeNumber}-${item.routeName}',
                                                                ),
                                                              ))
                                                          .toList(),
                                              onSelected: (TripRoute route) {
                                                if (mounted)
                                                  setState(() {
                                                    if (!_selectedRoutes
                                                        .contains(route)) {
                                                      _selectedRoutes
                                                          .add(route);
                                                      _routeList.remove(route);
                                                    }
                                                  });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              _labeledWidget(
                                'Shop Type',
                                DropdownButton<ShopType>(
                                  style: Theme.of(context).textTheme.bodyText2,
                                  value: _shopType,
                                  isDense: true,
                                  isExpanded: true,
                                  items: [
                                    if (_isEditMode &&
                                        widget.shop!.shopType ==
                                            ShopType.PARENT)
                                      DropdownMenuItem<ShopType>(
                                        child: Text('Parent'),
                                        value: ShopType.PARENT,
                                      ),
                                    if (_isEditMode &&
                                        widget.shop!.shopType == ShopType.CHILD)
                                      DropdownMenuItem<ShopType>(
                                        child: Text('Child'),
                                        value: ShopType.CHILD,
                                      ),
                                    if (!_isEditMode)
                                      DropdownMenuItem<ShopType>(
                                        child: Text('Parent'),
                                        value: ShopType.PARENT,
                                      ),
                                    if (!_isEditMode)
                                      DropdownMenuItem<ShopType>(
                                        child: Text('Child'),
                                        value: ShopType.CHILD,
                                      ),
                                  ],
                                  onChanged: (newValue) {
                                    if (_isEditMode) {
                                      return;
                                    }
                                    if (mounted)
                                      setState(() {
                                        _allChildShops
                                            .addAll(_selectedChildShops);
                                        _selectedChildShops = [];
                                        _selectedParentShop = null;
                                        _shopType = newValue!;
                                      });
                                  },
                                ),
                              ),
                              Visibility(
                                visible: _shopType == ShopType.CHILD,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: _labeledWidget(
                                    'Parent\nShop',
                                    DropdownButton<Shop>(
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                      value: _selectedParentShop,
                                      isDense: true,
                                      isExpanded: true,
                                      hint: Text('No Parent'),
                                      items: [
                                        DropdownMenuItem<Shop>(
                                          child: Text('No Parent'),
                                          onTap: () {
                                            _selectedParentShop = null;
                                          },
                                        ),
                                        ..._allParentShops.map((Shop value) {
                                          return DropdownMenuItem<Shop>(
                                            value: value,
                                            child: Text(value.shopName),
                                          );
                                        }).toList()
                                      ],
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedParentShop = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _shopType == ShopType.PARENT,
                                child: Container(
                                  width: 300,
                                  margin: EdgeInsets.only(top: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Child Shops',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          textAlign: TextAlign.left),
                                      SizedBox(height: 5),
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 10,
                                        runSpacing: 5,
                                        children: [
                                          ..._selectedChildShops
                                              .map((item) => Container(
                                                    width: 140,
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                primaryBorder),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    25))),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            '${item.shopName}',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption!
                                                                .copyWith(
                                                                    color:
                                                                        primaryTextDark),
                                                          ),
                                                        ),
                                                        CustomIconButton(
                                                            width: 20,
                                                            height: 20,
                                                            onPressed: () {
                                                              setState(() {
                                                                if (_selectedChildShops
                                                                    .contains(
                                                                        item)) {
                                                                  _allChildShops
                                                                      .add(
                                                                          item);
                                                                  _selectedChildShops
                                                                      .remove(
                                                                          item);
                                                                }
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.close,
                                                              size: 16,
                                                              color: red,
                                                            )),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                          _allChildShops.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    'No more shops to add.',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!,
                                                  ),
                                                )
                                              : Container(
                                                  width: 140,
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: primaryBorder),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25))),
                                                  child: PopupMenuButton<Shop>(
                                                    tooltip: 'Add Shop',
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Add Shop',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                                  color:
                                                                      primaryTextDark,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                        ),
                                                        Icon(
                                                          Icons.add,
                                                          size: 16,
                                                          color: primaryDark,
                                                        ),
                                                      ],
                                                    ),
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        _allChildShops
                                                            .map((item) =>
                                                                PopupMenuItem<
                                                                    Shop>(
                                                                  value: item,
                                                                  child: Text(
                                                                    '${item.shopName}',
                                                                  ),
                                                                ))
                                                            .toList(),
                                                    onSelected: (Shop shop) {
                                                      setState(() {
                                                        if (!_selectedChildShops
                                                            .contains(shop)) {
                                                          _selectedChildShops
                                                              .add(shop);
                                                          _allChildShops
                                                              .remove(shop);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              CustomInputField(
                                width: 300,
                                readOnly: _isEditMode,
                                hint: 'Old Closing Balance',
                                controller: _closingBalanceController,
                                keyboardType: TextInputType.number,
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d{0,2}')),
                                ],
                              ),
                              SizedBox(height: 15),
                              CustomInputField(
                                width: 300,
                                hint: 'Max allowed Credit',
                                controller: _shopCreditController,
                                keyboardType: TextInputType.number,
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d{0,2}')),
                                ],
                              ),
                              SizedBox(height: 15),
                              CustomInputField(
                                width: 300,
                                hint: 'Janadha rate (per kg)',
                                controller: _shopJanadhaRateController,
                                keyboardType: TextInputType.number,
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d{0,2}')),
                                ],
                              ),
                              Container(
                                width: 300,
                                alignment: Alignment.centerLeft,
                                child: Text('Discount per KG.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left),
                              ),
                              SizedBox(height: 5),
                              Container(
                                width: 300,
                                alignment: Alignment.centerLeft,
                                child: Text('Delivery Discount',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left),
                              ),
                              SizedBox(height: 3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomInputField(
                                    width: 140,
                                    hint: 'Regular',
                                    keyboardType: TextInputType.number,
                                    controller: _regularDiscountController,
                                    textInputFormatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d{0,2}')),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  CustomInputField(
                                    width: 140,
                                    hint: 'Small',
                                    keyboardType: TextInputType.number,
                                    controller: _smallDiscountController,
                                    textInputFormatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d{0,2}')),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              SizedBox(height: 5),
                              Container(
                                width: 300,
                                alignment: Alignment.centerLeft,
                                child: Text('Shop Discount',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left),
                              ),
                              SizedBox(height: 3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomInputField(
                                    width: 140,
                                    hint: 'Regular',
                                    keyboardType: TextInputType.number,
                                    controller: _shopRegularDiscountController,
                                    textInputFormatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d{0,2}')),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  CustomInputField(
                                    width: 140,
                                    hint: 'Small',
                                    keyboardType: TextInputType.number,
                                    controller: _shopSmallDiscountController,
                                    textInputFormatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^-?\d*\.?\d{0,2}')),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              UploadButton(
                                width: 300,
                                onSelectPressed: () async {
                                  _shopPhoto = await showImagePicker();
                                  setState(() {});
                                },
                                onClearPressed: () {
                                  setState(() {
                                    _shopPhoto = null;
                                  });
                                },
                                label: 'Shop Photo',
                                fileName: _shopPhoto == null
                                    ? null
                                    : _shopPhoto!.name,
                              ),
                              SizedBox(height: 15),
                              UploadButton(
                                width: 300,
                                onSelectPressed: () async {
                                  _ownerPhoto = await showImagePicker();
                                  setState(() {});
                                },
                                onClearPressed: () {
                                  setState(() {
                                    _ownerPhoto = null;
                                  });
                                },
                                label: 'Owner Photo',
                                fileName: _ownerPhoto == null
                                    ? null
                                    : _ownerPhoto!.name,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(_errorMessage,
                          style: Theme.of(context).textTheme.caption?.copyWith(
                                color: red,
                              )),
                      SizedBox(height: 20),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        Row(
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

                                if (_selectedRegion == null) {
                                  setState(() {
                                    _errorMessage = 'Please select a Region.';
                                  });
                                  return;
                                }

                                if (_locationController.text.isEmpty) {
                                  lat = '0';
                                  log = '0';
                                } else {
                                  int? ind1;
                                  int? ind2;
                                  int? ind3;

                                  ind1 = _locationController.text.indexOf('@');
                                  if (ind1 != -1) {
                                    ind2 = _locationController.text
                                        .indexOf(',', ind1);
                                    ind3 = _locationController.text
                                        .lastIndexOf(',');
                                    try {
                                      lat = _locationController.text
                                          .substring(ind1 + 1, ind2);
                                      log = _locationController.text
                                          .substring(ind2 + 1, ind3);
                                    } catch (err) {
                                      print(err);
                                      setState(() {
                                        _errorMessage =
                                            'Please enter a valid location';
                                      });
                                      return;
                                    }
                                  } else {
                                    setState(() {
                                      _errorMessage =
                                          'Please enter a valid location';
                                    });
                                    return;
                                  }
                                }

                                setState(() {
                                  _errorMessage = '';
                                });

                                _showOverlayProgress();
                                var shopList = [];
                                for (var shop in _selectedChildShops) {
                                  shopList.add(shop.docID);
                                }

                                List<String> routeList = [];
                                _selectedRoutes.forEach((element) {
                                  routeList.add(element!.docID!);
                                });

                                bool res = false;
                                if (_isEditMode) {
                                  //update
                                  final shop = widget.shop!.clone();

                                  shop.shopName =
                                      _shopNameController.text.trim();

                                  shop.address = _addressController.text.trim();
                                  shop.ownerName =
                                      _ownerNameController.text.trim();
                                  shop.location = GeoPoint(
                                      double.parse(lat!.toString()),
                                      double.parse(log!.toString()));
                                  shop.regionName = _selectedRegion!.regionName;
                                  shop.routeIDs = routeList; //area
                                  shop.parentShop = _selectedParentShop?.docID;
                                  shop.childShops = shopList;
                                  shop.smallDiscountPerKG = double.parse(
                                      _smallDiscountController.text.isEmpty
                                          ? '0'
                                          : _smallDiscountController.text);
                                  shop.regularDiscountPerKG = double.parse(
                                      _regularDiscountController.text.isEmpty
                                          ? '0'
                                          : _regularDiscountController.text);
                                  shop.shopRegularDiscountPerKG = double.parse(
                                      _shopRegularDiscountController
                                              .text.isEmpty
                                          ? '0'
                                          : _shopRegularDiscountController
                                              .text);
                                  shop.shopSmallDiscountPerKG = double.parse(
                                      _shopSmallDiscountController.text.isEmpty
                                          ? '0'
                                          : _shopSmallDiscountController.text);
                                  shop.closingBalance = double.parse(
                                      _closingBalanceController.text.isEmpty
                                          ? '0'
                                          : _closingBalanceController.text);
                                  shop.maxAllowedCredit = double.parse(
                                      _shopCreditController.text.isEmpty
                                          ? '0'
                                          : _shopCreditController.text);
                                  shop.janadhaRate = double.parse(
                                      _shopJanadhaRateController.text.isEmpty
                                          ? '0'
                                          : _shopJanadhaRateController.text);
                                  shop.phoneNumber =
                                      _isoController.text.trim() +
                                          _phoneController.text.trim();
                                  res = await _shopDB.updateShop(
                                      newShop: shop,
                                      oldShop: widget.shop!,
                                      ownerPhoto: _ownerPhoto,
                                      shopPhoto: _shopPhoto);
                                } else {
                                  //create
                                  final shop = Shop(
                                    boxesInShop: 0,
                                    notes: '',
                                    closingBalance: double.parse(
                                        _closingBalanceController.text.isEmpty
                                            ? '0'
                                            : _closingBalanceController.text),
                                    routeIDs: routeList,
                                    shopType: _shopType,
                                    parentShop: _selectedParentShop?.docID,
                                    childShops: shopList,
                                    smallDiscountPerKG: double.parse(
                                        _smallDiscountController.text.isEmpty
                                            ? '0'
                                            : _smallDiscountController.text),
                                    regularDiscountPerKG: double.parse(
                                        _regularDiscountController.text.isEmpty
                                            ? '0'
                                            : _regularDiscountController.text),
                                    shopRegularDiscountPerKG: double.parse(
                                        _shopRegularDiscountController
                                                .text.isEmpty
                                            ? '0'
                                            : _shopRegularDiscountController
                                                .text),
                                    shopSmallDiscountPerKG: double.parse(
                                        _shopSmallDiscountController
                                                .text.isEmpty
                                            ? '0'
                                            : _shopSmallDiscountController
                                                .text),
                                    ownerName: _ownerNameController.text.trim(),
                                    shopName: _shopNameController.text.trim(),
                                    address: _addressController.text.trim(),
                                    regionName: _selectedRegion!.regionName,
                                    addedTime: DateTime.now(),
                                    location: GeoPoint(
                                        double.parse(lat!.toString()),
                                        double.parse(log!.toString())),
                                    phoneNumber: _isoController.text.trim() +
                                        _phoneController.text.trim(),
                                    maxAllowedCredit: double.parse(
                                        _shopCreditController.text.isEmpty
                                            ? '0'
                                            : _shopCreditController.text),
                                    janadhaRate: double.parse(
                                        _shopJanadhaRateController.text.isEmpty
                                            ? '0'
                                            : _shopJanadhaRateController.text),
                                  );
                                  res = await _shopDB.createShop(
                                      shop: shop,
                                      shopPhoto: _shopPhoto,
                                      ownerPhoto: _ownerPhoto);
                                }
                                _hideOverlayProgress();

                                if (res) {
                                  Fluttertoast.showToast(
                                      msg: _isEditMode
                                          ? 'Shop Updated'
                                          : 'Shop Created!',
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
                                      msg: _isEditMode
                                          ? 'Unable to update. Try again.'
                                          : 'Unable to create. Try again.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      webBgColor:
                                          'linear-gradient(to right, #ff0000, #ff0000)',
                                      fontSize: 16.0);
                                }
                              },
                              text: _isEditMode ? 'Update' : 'Add',
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
      ),
    );
  }

  Widget _labeledWidget(String label, Widget child) {
    return Container(
      // width: 300,
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.subtitle1),
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
