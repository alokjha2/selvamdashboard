import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selvam_broilers/widgets/sidebar.dart';

import '../utils/colors.dart';
import '../utils/style.dart';

//enum AppBarState { COLLAPSED, SEMI_EXPANDED, EXPANDED }

class TopAppBar extends StatefulWidget {
  final List<NavBarItem> items;

  const TopAppBar({Key? key, required this.items}) : super(key: key);
  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  int _selectedNavIndex = 0;
  //NavBarState _navBarState = NavBarState.EXPANDED;

  double startPos = -1.0;
  double endPos = 0.0;
  Curve curve = Curves.decelerate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,

            //width: _navBarExpandedWidth,
            child: TweenAnimationBuilder(
              tween: Tween<Offset>(
                  begin: Offset(startPos, 0), end: Offset(endPos, 0)),
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
                  //  if (_navBarState == NavBarState.COLLAPSED) _navBarExpandedWidth = 0;
                });
              },
              child: Container(
                //width : 600,
                //width: double.infinity,
                //constraints: BoxConstraints.tightForFinite(width: double.infinity),
                color: primary,
                child: ListView.builder(
                    primary: true,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _listTile(widget.items[index], index);
                    }),
              ),
            )),
      ],
    );
  }

  Widget _listTile(NavBarItem item, index) {
    bool isSelected = _selectedNavIndex == index;

    return Material(
      color: isSelected ? selectedBGColor.withAlpha(20) : transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
          item.onPressed?.call();
        },
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 5,
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    item.iconPath,
                    width: 16,
                    height: 16,

                    //color : red,
                    color: isSelected ? selectedColor : unselectedColor,
                    // color: isSelected ? selectedColor : unselectedColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                        color: isSelected ? selectedColor : unselectedColor),
                  ),
                ],
              ),
            ),
            Container(
              // width: Size.infinite,
              // width:  double.infinity,
              width: (item.title.length * 10).toDouble(),
              height: 3,
              color: isSelected ? selectedColor : transparent,
            ),
          ],
        ),
      ),
    );
  }
}
