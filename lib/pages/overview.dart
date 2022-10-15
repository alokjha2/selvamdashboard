import 'package:flutter/material.dart';
import '../utils/colors.dart';

class OverviewWidget extends StatefulWidget {
  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(15.0),
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          border: Border.all(
            color: primaryBorder,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8.0,
                spreadRadius: 5.0),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Overview',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: primary),
            ),
          ),
          Container(
            margin: EdgeInsets.all(15.0),
            padding: EdgeInsets.all(15.0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statCard('Drivers online', '3'),
                _statCard('Total orders', '11'),
                _statCard('Ongoing', '8'),
                _statCard('Completed', '3'),
                SizedBox(
                  width: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: 200,
      height: 100,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
        border: Border.all(
          color: primaryBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: grayDark),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headline1,
          ),
        ],
      ),
    );
  }
}
