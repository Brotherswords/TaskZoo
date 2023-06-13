import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Problem add False to the queue when the task is not completed

class DailyTaskCard extends StatefulWidget {
  final String title;
  final String tag;
  final List<bool> daysOfWeek;
  final bool biDaily;

  DailyTaskCard({
    required this.title,
    required this.tag,
    required this.daysOfWeek,
    required this.biDaily,
  });

  @override
  _DailyTaskCardState createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<DailyTaskCard> {
  bool isCompleted = false;
  late DateTime previousDate;
  final Queue<bool> completionStatusQueue = Queue<bool>();
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    previousDate = DateTime.now();
    completionStatusQueue
        .add(false); // Initialize the queue with a default value
  }

  @override
  Widget build(BuildContext context) {
    // Determine if today is in daysOfWeek
    final now = DateTime.now();
    bool isTodayInDaysOfWeek = widget.daysOfWeek[now.weekday - 1];

    if (widget.biDaily) {
      final dayDifference = now.difference(previousDate).inDays;
      if (dayDifference > 1) {
        if (dayDifference <= 3) {
          previousDate = previousDate.add(const Duration(days: 2));
        } else {
          previousDate = now;
        }
      }
      isTodayInDaysOfWeek = previousDate.year == now.year &&
          previousDate.month == now.month &&
          previousDate.day == now.day;
    }

    if (isTodayInDaysOfWeek && isCompleted) {
      completionStatusQueue.add(true);
      if (completionStatusQueue.length > 30) {
        completionStatusQueue.removeFirst();
      }
    }

    final completionCount =
        completionStatusQueue.where((completed) => completed == true).length;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (!_isTapped) {
              _isTapped = true;
            } else {
              _isTapped = false;
            }
          });
        },
        onLongPress: isTodayInDaysOfWeek && !_isTapped
            ? () {
                setState(() {
                  isCompleted = true;
                });
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).unselectedWidgetColor,
          ),
          child: Opacity(
            opacity: isTodayInDaysOfWeek ? 1 : 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!_isTapped)
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isTodayInDaysOfWeek
                                    ? Colors.black
                                    : Theme.of(context).dividerColor,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              widget.tag,
                              style: TextStyle(
                                color: isTodayInDaysOfWeek
                                    ? Colors.grey
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!_isTapped)
                  Container(
                    height: 1.0,
                    color: Theme.of(context).dividerColor,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: _isTapped
                        ? Text(
                            'Completed ${completionCount.toString()} times in the last 30 days',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          )
                        : isTodayInDaysOfWeek
                            ? !isCompleted
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(FontAwesomeIcons.clock),
                                      const SizedBox(width: 8.0),
                                      Text(_getTimeUntilMidnight()),
                                    ],
                                  )
                                : const Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.black,
                                  )
                            : const Text('Relax, not for today'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final difference = midnight.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return hours > 0 ? "$hours hours left" : "$minutes minutes left";
  }
}
