import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selvam_broilers/utils/utils.dart';

import '../utils/colors.dart';
import '../utils/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum NavBarState { COLLAPSED, SEMI_EXPANDED, EXPANDED }

class SideBar extends StatefulWidget {
  final List<NavBarItem> items;

  const SideBar({Key? key, required this.items}) : super(key: key);
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedNavIndex = 0;
  double _navBarExpandedWidth = 240.w;
  NavBarState _navBarState = NavBarState.EXPANDED;

  double startPos = -1.0;
  double endPos = 0.0;
  Curve curve = Curves.decelerate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (isTab()) {
      _collapsNavBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _navBarExpandedWidth,
      child: TweenAnimationBuilder(
        tween:
            Tween<Offset>(begin: Offset(startPos, 0), end: Offset(endPos, 0)),
        duration: Duration(milliseconds: 200),
        curve: curve,
        builder: (context, Offset offset, child) {
          return FractionalTranslation(
            translation: offset,
            child: Container(
              width: double.infinity,
              child: Center(
                child: child,
              ),
            ),
          );
        },
        onEnd: () {
          setState(() {
            if (_navBarState == NavBarState.COLLAPSED)
              _navBarExpandedWidth = 60;
          });
        },
        child: Column(
          children: [
            Container(
              color: primary,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: (_navBarState == NavBarState.EXPANDED)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 24,
                      color: primaryDark,
                    ),
                    if (_navBarState == NavBarState.EXPANDED)
                      SizedBox(width: 10),
                    if (_navBarState == NavBarState.EXPANDED)
                      Text(
                        'Selvam Broilers',
                        style: getAppTheme().textTheme.headline4,
                      ),
                  ],
                ),
              ),
              alignment: Alignment.center,
            ),
            Expanded(
              child: Container(
                color: primary,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _listTile(widget.items[index], index);
                      }),
                ),
              ),
            ),
            Container(
              color: primary,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      _navBarState == NavBarState.EXPANDED
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: primaryTextDark,
                    ),
                    onPressed: () {
                      if (_navBarState == NavBarState.EXPANDED) {
                        _collapsNavBar();
                      } else {
                        _expandNavBar();
                      }
                    },
                  ),
                ],
              ),
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }

  void _expandNavBar() {
    setState(() {
      _navBarExpandedWidth = 240.w;
      _navBarState = NavBarState.EXPANDED;
      // startPos = -1.0;
      // endPos = 0.0;
    });
  }

  void _collapsNavBar() {
    setState(() {
      _navBarState = NavBarState.COLLAPSED;
      _navBarExpandedWidth = 60.w;
      // startPos = 0.0;
      // endPos = -1.0;
    });
  }

  Widget _listTile(NavBarItem item, index) {
    bool isSelected = _selectedNavIndex == index;
    return Container(
      width: _navBarExpandedWidth,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Material(
        color: isSelected ? selectedColor : transparent,
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () {
            setState(() {
              _selectedNavIndex = index;
            });
            item.onPressed?.call();
          },
          child: Row(
            mainAxisAlignment: (_navBarState == NavBarState.EXPANDED)
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              SizedBox(height: 46),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          item.iconPath,
                          width: 16.r,
                          height: 16.r,
                          color: isSelected ? primaryDark : primaryTextDark,
                        ),
                      ],
                    ),
                    if (_navBarState == NavBarState.EXPANDED)
                      SizedBox(width: 20),
                    if (_navBarState == NavBarState.EXPANDED)
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            color: isSelected ? primaryDark : primaryTextDark),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarItem {
  final Function? onPressed;
  final String title;
  final String iconPath;
  NavBarItem({this.onPressed, required this.iconPath, required this.title});
}
