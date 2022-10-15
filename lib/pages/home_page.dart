import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selvam_broilers/widgets/sidebar.dart';
import '../models/trip.dart';
import '../widgets/sale/manage_sale_order_page.dart';
import '../widgets/shop/manage_shops_page.dart';
import 'package:selvam_broilers/services/auth.dart';
import '../utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

bool isPhoneSelected = false;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget mainWidget = ManageSaleOrdersWidget();
  Widget? _driversViewWidget;
  Widget? _loadManWidget;
  Widget? _vehiclesViewWidget;
  Widget? _routesViewWidget;
  // Widget? _regionWidget;
  // Widget? _reportViewPage;
  Widget? _tripsViewWidget;
  Widget? _shopsViewWidget;
  Widget? _farmsViewWidget;
  Widget? _ordersViewWidget;
  Widget? _salesViewsWidget;
  Widget? _directSalesViewsWidget;
  Widget? _collectionAgentWidget;
  Widget? _collectionsWidget;
  Widget? _reportViewPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: size.width,
        child: _getRootWidget(),
      ),
    );
  }

  Widget _getRootWidget() {
    final userAgent = html.window.navigator.userAgent.toString().toLowerCase();

    if (userAgent.contains('iphone') || userAgent.contains('android')) {
      setState(() {
        isPhoneSelected = true;
      });
    } else {
      setState(() {
        isPhoneSelected = false;
      });
    }

    return Row(
      children: [
        SideBar(
          items: [

            NavBarItem(
                iconPath: 'assets/icons/sale.svg',
                title: 'Sale Orders',
                onPressed: () {
                  if (_salesViewsWidget == null)
                    _salesViewsWidget = ManageSaleOrdersWidget();
                  _onMenuItemPressed(_salesViewsWidget);
                }),


            NavBarItem(
                iconPath: 'assets/icons/store.svg',
                title: 'Shops',
                onPressed: () {
                  if (_shopsViewWidget == null)
                    _shopsViewWidget = ManageShopsWidget();
                  _onMenuItemPressed(_shopsViewWidget);
                }),
                
            NavBarItem(
                iconPath: 'assets/icons/logout.svg',
                title: 'Logout',
                onPressed: () {
                  FirebaseAuthService().signOut();
                }),
          ],
        ),
        Flexible(
          flex: 10,
          child: Container(
            color: background,
            child: mainWidget,
          ),
        ),
      ],
    );
  }

  void _onMenuItemPressed(Widget? destinationWidget) {
    setState(() {
      mainWidget = destinationWidget!;
    });
  }
}
