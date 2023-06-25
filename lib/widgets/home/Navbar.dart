import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  // icon sizes
  final double dotIconSize = 15;
  final double otherIconSize = 25;

  final int currentIndex;
  final Function onTap;

  CustomNavBar({required this.currentIndex, required this.onTap});

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).unselectedWidgetColor,
      child: SafeArea(
        child: Container(
          height: 50,
          color: Theme.of(context).unselectedWidgetColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    color: Theme.of(context).indicatorColor,
                    icon: Icon(Icons.pie_chart_outline),
                    onPressed: () {
                      widget.onTap(0);
                    },
                    iconSize: widget.otherIconSize,
                  ),
                  IconButton(
                    color: Theme.of(context).indicatorColor,
                    icon: Icon(Icons.settings_outlined),
                    onPressed: () {
                      widget.onTap(3);
                    },
                    iconSize: widget.otherIconSize,
                  ),
                ],
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: widget.currentIndex == 1
                          ? Theme.of(context).indicatorColor
                          : Theme.of(context).dividerColor,
                      icon: Icon(Icons.fiber_manual_record),
                      onPressed: () {
                        widget.onTap(1);
                      },
                      iconSize: widget.dotIconSize,
                    ),
                    IconButton(
                      color: widget.currentIndex == 2
                          ? Theme.of(context).indicatorColor
                          : Theme.of(context).dividerColor,
                      icon: Icon(Icons.fiber_manual_record),
                      onPressed: () {
                        widget.onTap(2);
                      },
                      iconSize: widget.dotIconSize,
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