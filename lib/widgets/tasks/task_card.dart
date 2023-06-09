import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taskzoo/widgets/tasks/edit_task.dart';

String startOfWeek = "Monday";

class TaskCard extends StatefulWidget {
  String title;
  String tag;
  String schedule;
  List<bool> daysOfWeek;
  bool biDaily;
  bool weekly;
  bool monthly;
  int timesPerMonth;
  int timesPerWeek;
  bool isCompleted = false;
  int streakCount = 0;
  int longestStreak = 0;
  bool isMeantForToday = true;
  int currentCycleCompletions = 0;
  List<DateTime> last30DaysDates = [];
  int completionCount30days = 0;
  Set<DateTime> completedDates = HashSet<DateTime>();
  DateTime previousDate = DateTime.now();
  DateTime nextCompletionDate = DateTime.now();
  bool isStreakContinued = false;

  TaskCard({
    Key? key,
    required this.title,
    required this.tag,
    required this.daysOfWeek,
    required this.biDaily,
    required this.weekly,
    required this.monthly,
    required this.timesPerMonth,
    required this.timesPerWeek,
    required this.schedule,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isTapped = false;

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title ||
        widget.tag != oldWidget.tag ||
        widget.daysOfWeek != oldWidget.daysOfWeek ||
        widget.biDaily != oldWidget.biDaily ||
        widget.weekly != oldWidget.weekly ||
        widget.monthly != oldWidget.monthly ||
        widget.timesPerMonth != oldWidget.timesPerMonth ||
        widget.timesPerWeek != oldWidget.timesPerWeek ||
        widget.schedule != oldWidget.schedule) {
      // Trigger an update by calling setState
      setState(() {});
    }
  }

  //Make modifications to previous date when storing data persistently
  @override
  void initState() {
    super.initState();
    widget.nextCompletionDate = calculateNextCompletionDate(
        determineFrequency(
          widget.daysOfWeek,
          widget.biDaily,
          widget.weekly,
          widget.monthly,
        ),
        widget.previousDate);
    widget.last30DaysDates = _getLast30DaysDates();
    widget.completionCount30days = _getCompletionCount(widget.last30DaysDates);
  }

  @override
  Widget build(BuildContext context) {
    String schedule = determineFrequency(
      widget.daysOfWeek,
      widget.biDaily,
      widget.weekly,
      widget.monthly,
    );

    String monthlyOrWeekly = (schedule == "monthly") ? "month" : "week";

    print("Created TaskCard");

    //Reset completion
    _completionResetHandler();

    //Handle setting and resetting stats based on the schedule
    _streakAndStatsHandler(schedule);

    //Handles Weekly/Monthly completions
    _setCompletionStatus(schedule);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isTapped = !_isTapped;
          });
        },
        onLongPress: !widget.isCompleted && !_isTapped
            ? () {
                setState(() {
                  widget.isCompleted = true;
                  _streakAndStatsHandler(schedule);
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
            opacity: widget.isMeantForToday ? 1 : 0.5,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!_isTapped)
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.isMeantForToday
                                        ? Colors.black
                                        : Theme.of(context).dividerColor,
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  widget.tag,
                                  style: TextStyle(
                                    color: widget.isMeantForToday
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
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        widget.streakCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        widget.longestStreak.toString(),
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.calendar_month,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        widget.completionCount30days.toString(),
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : widget.isMeantForToday
                                ? !widget.isCompleted
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Icon(
                                                  FontAwesomeIcons.clock),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                  _getTimeUntilNextCompletionDate()),
                                            ],
                                          ),
                                          if (_setCompletionStatus(schedule) >
                                              0)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                '${_setCompletionStatus(schedule)} more this $monthlyOrWeekly',
                                              ),
                                            ),
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
                if (_isTapped)
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet<Map<String, dynamic>>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return EditTaskSheet(
                              title: widget.title,
                              tag: widget.tag,
                              daysOfWeek: widget.daysOfWeek,
                              biDaily: widget.biDaily,
                              weekly: widget.weekly,
                              monthly: widget.monthly,
                              timesPerWeek: widget.timesPerWeek,
                              timesPerMonth: widget.timesPerMonth,
                              onUpdateTask: (editedTaskData) {
                                if (editedTaskData != null) {
                                  // Update the task data in the TaskCard widget
                                  setState(() {
                                    widget.title = editedTaskData['title'];
                                    widget.tag = editedTaskData['tag'];
                                    widget.daysOfWeek =
                                        editedTaskData['daysOfWeek'];
                                    widget.biDaily = editedTaskData['biDaily'];
                                    widget.weekly = editedTaskData['weekly'];
                                    widget.monthly = editedTaskData['monthly'];
                                    widget.timesPerWeek =
                                        editedTaskData['timesPerWeek'];
                                    widget.timesPerMonth =
                                        editedTaskData['timesPerMonth'];
                                    widget.schedule =
                                        editedTaskData['schedule'];
                                    isCompletedFalse(schedule);
                                  });
                                }
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Rest of the code remains the same...

  void isCompletedFalse(String schedule) {
    if (widget.completedDates.isNotEmpty) {
      DateTime earliestDate =
          widget.completedDates.reduce((a, b) => a.isBefore(b) ? a : b);
      widget.completedDates.remove(earliestDate);
      setState(() {
        widget.isCompleted = false;
      });
    }
  }

  String determineFrequency(
    List<bool> daysOfWeek,
    bool biDaily,
    bool weekly,
    bool monthly,
  ) {
    if (daysOfWeek.any((day) => day == true)) {
      return 'custom';
    } else if (weekly) {
      return 'weekly';
    } else if (monthly) {
      return 'monthly';
    } else if (biDaily) {
      return 'biDaily';
    } else {
      return 'daily';
    }
  }

  String _getTimeUntilNextCompletionDate() {
    final now = DateTime.now();
    final difference = widget.nextCompletionDate.difference(now);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 1) {
      return "$days days left";
    } else if (days == 1) {
      return "1 day left";
    } else if (hours > 0) {
      return "$hours hours left";
    } else {
      return "$minutes minutes left";
    }
  }

  List<DateTime> _getLast30DaysDates() {
    final today = DateTime.now();
    final last30DaysDates = <DateTime>[];
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      last30DaysDates.add(DateTime(date.year, date.month, date.day));
    }
    return last30DaysDates;
  }

  int _getCompletionCount(List<DateTime> last30DaysDates) {
    int count = 0;
    for (final date in last30DaysDates) {
      if (widget.completedDates.contains(date)) {
        count++;
      }
    }
    return count;
  }

  int _setCompletionStatus(String schedule) {
    int remainingCompletions = 0;
    if (schedule == "weekly") {
      if (widget.currentCycleCompletions < widget.timesPerWeek) {
        widget.isCompleted = false;
        remainingCompletions =
            widget.timesPerWeek - widget.currentCycleCompletions;
        return remainingCompletions;
      } else {
        return 0;
      }
    } else if (schedule == "monthly") {
      if (widget.currentCycleCompletions < widget.timesPerMonth) {
        widget.isCompleted = false;
        remainingCompletions =
            widget.timesPerMonth - widget.currentCycleCompletions;
        return remainingCompletions;
      } else {
        return 0;
      }
    } else {
      return -1;
    }
  }

  //TODO: Refactor this method before release
  void _streakAndStatsHandler(String schedule) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day, 0, 0, 0);
    if (schedule == "daily") {
      widget.isStreakContinued = now.isBefore(widget.nextCompletionDate);
      if (widget.isStreakContinued && widget.isCompleted) {
        if (!widget.completedDates.contains(today)) {
          widget.completedDates.add(today);
          widget.last30DaysDates = _getLast30DaysDates();
          widget.completionCount30days =
              _getCompletionCount(widget.last30DaysDates);
          widget.streakCount++;
          if (widget.streakCount > widget.longestStreak) {
            widget.longestStreak = widget.streakCount;
          }
          widget.previousDate = today;
          widget.nextCompletionDate =
              calculateNextCompletionDate(schedule, widget.previousDate);
        }
      }
      if (!widget.isStreakContinued) {
        widget.streakCount = 0;
        widget.nextCompletionDate =
            calculateNextCompletionDate(schedule, DateTime.now());
      }
    } else if (schedule == "custom") {
      //Requires further testing
      widget.isMeantForToday = widget.daysOfWeek[now.weekday - 1];
      widget.isStreakContinued =
          widget.previousDate.isBefore(widget.nextCompletionDate) ||
              !widget.isMeantForToday;
      if (widget.isStreakContinued &&
          widget.isCompleted &&
          widget.isMeantForToday) {
        if (!widget.completedDates.contains(today)) {
          if (widget.isMeantForToday) {
            widget.completedDates.add(today);
            widget.last30DaysDates = _getLast30DaysDates();
            widget.completionCount30days =
                _getCompletionCount(widget.last30DaysDates);
            widget.streakCount++;
            if (widget.streakCount > widget.longestStreak) {
              widget.longestStreak = widget.streakCount;
            }
            widget.previousDate = today;
            widget.nextCompletionDate =
                calculateNextCompletionDate(schedule, widget.previousDate);
          }
        }
      }
      if (!widget.isStreakContinued) {
        widget.streakCount = 0;
        widget.nextCompletionDate =
            calculateNextCompletionDate(schedule, DateTime.now());
      }
    } else if (schedule == "biDaily") {
      widget.isStreakContinued = now.isBefore(widget.nextCompletionDate);
      if (widget.isStreakContinued && widget.isCompleted) {
        if (!widget.completedDates.contains(today)) {
          widget.completedDates.add(today);
          widget.last30DaysDates = _getLast30DaysDates();
          widget.completionCount30days =
              _getCompletionCount(widget.last30DaysDates);
          widget.streakCount++;
          if (widget.streakCount > widget.longestStreak) {
            widget.longestStreak = widget.streakCount;
          }
          widget.previousDate = today;
          widget.nextCompletionDate =
              calculateNextCompletionDate(schedule, widget.previousDate);
        }
      }
      if (!widget.isStreakContinued) {
        widget.streakCount = 0;
        widget.nextCompletionDate =
            calculateNextCompletionDate(schedule, DateTime.now());
      }
    } else if (schedule == "weekly") {
      widget.isStreakContinued = now.isBefore(widget.nextCompletionDate);
      if (widget.isStreakContinued && widget.isCompleted) {
        if (!widget.completedDates.contains(today)) {
          _getCompletionCount(widget.last30DaysDates);
          widget.currentCycleCompletions++;
          if (widget.currentCycleCompletions < widget.timesPerWeek) {
            return;
          }
          widget.completedDates.add(today);
          widget.last30DaysDates = _getLast30DaysDates();
          widget.completionCount30days = widget.streakCount++;
          widget.longestStreak = max(widget.longestStreak, widget.streakCount);
          widget.previousDate = today;
          widget.nextCompletionDate =
              calculateNextCompletionDate(schedule, widget.previousDate);
        }
      }
      if (!widget.isStreakContinued) {
        widget.streakCount = 0;
        widget.nextCompletionDate =
            calculateNextCompletionDate(schedule, DateTime.now());
      }
    } else if (schedule == "monthly") {
      widget.isStreakContinued = now.isBefore(widget.nextCompletionDate);
      if (widget.isStreakContinued && widget.isCompleted) {
        if (!widget.completedDates.contains(today)) {
          _getCompletionCount(widget.last30DaysDates);
          widget.currentCycleCompletions++;
          if (widget.currentCycleCompletions < widget.timesPerMonth) {
            return;
          }
          widget.completedDates.add(today);
          widget.last30DaysDates = _getLast30DaysDates();
          widget.completionCount30days = widget.streakCount++;
          widget.longestStreak = max(widget.longestStreak, widget.streakCount);
          widget.previousDate = today;
          widget.nextCompletionDate =
              calculateNextCompletionDate(schedule, widget.previousDate);
        }
      }
      if (!widget.isStreakContinued) {
        widget.streakCount = 0;
        widget.nextCompletionDate =
            calculateNextCompletionDate(schedule, DateTime.now());
      }
    }
  }

  //TODO: Remove Print Statements before release
  void _completionResetHandler() {
    if (widget.isCompleted &&
        !(widget.completedDates.contains(DateTime(DateTime.now().year,
            DateTime.now().month, DateTime.now().day, 0, 0, 0)))) {
      print("resetting completion");
      print(widget.completedDates);
      print(widget.isCompleted);
      widget.isCompleted = false;
    } else {
      print("No Reset");
      print(widget.isCompleted);
    }
  }

  DateTime calculateNextCompletionDate(
      String schedule, DateTime previousCompletionDate) {
    DateTime nextValidDate = previousCompletionDate;

    switch (schedule) {
      case 'daily':
        return previousCompletionDate.add(const Duration(days: 1));
      case 'custom':
        final mondayShifted = shiftRight(widget.daysOfWeek, 1);
        final daysOfWeek = widget.daysOfWeek;
        final currentDay = previousCompletionDate.weekday;
        final nextValidDay = (currentDay) % 7; // Get the next day index
        final now = DateTime.now();

        if (mondayShifted[nextValidDay] == true) {
          nextValidDate = DateTime(now.year, now.month, now.day)
              .add(const Duration(hours: 23, minutes: 59));
          return nextValidDate;
        }

        // Find the next true day of the week
        int count = 0;
        for (int i = nextValidDay; i < 7; i++) {
          count++;
          if (daysOfWeek[i]) {
            nextValidDate = DateTime(now.year, now.month, now.day + count)
                .add(const Duration(hours: 23, minutes: 59));
            break;
          }
        }
        return nextValidDate;
      case 'weekly':
        final currentDate = DateTime.now();
        final currentDay = currentDate.weekday;
        final daysUntilNextMonday = (8 - currentDay) % 7;
        final nextMonday = currentDate.add(Duration(days: daysUntilNextMonday));
        final nextMondayAtMidnight =
            DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
        return nextMondayAtMidnight;

      case 'monthly':
        if (previousCompletionDate.month == 12) {
          nextValidDate = DateTime(previousCompletionDate.year + 1, 1, 1);
        } else {
          nextValidDate = DateTime(
              previousCompletionDate.year, previousCompletionDate.month + 1, 1);
        }
        return nextValidDate;
      case 'biDaily':
        return previousCompletionDate.add(const Duration(days: 2));
      default:
        return previousCompletionDate.add(const Duration(days: 1));
    }
  }

  int _getNextValidDay(int currentDay, String startOfWeek) {
    final daysOfWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    final startDayIndex = daysOfWeek.indexOf(startOfWeek);
    final nextValidDayIndex = (startDayIndex + 7 - currentDay) % 7;
    return nextValidDayIndex;
  }

  int _getDaysToAdd(int currentDay, int nextValidDay) {
    return nextValidDay >= currentDay
        ? nextValidDay - currentDay
        : (nextValidDay + 7) - currentDay;
  }

  DateTime _getStartOfWeek(DateTime date, String startOfWeek) {
    final daysOfWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    final startDayIndex = daysOfWeek.indexOf(startOfWeek);
    final currentDayIndex = date.weekday - 1;
    final daysToAdd = startDayIndex >= currentDayIndex
        ? startDayIndex - currentDayIndex
        : (startDayIndex + 7) - currentDayIndex;
    return date.add(Duration(days: daysToAdd));
  }

  List<bool> shiftRight(List<bool> array, int n) {
    List<bool> shiftedArray = List.from(array);
    final int size = array.length;

    for (int i = 0; i < size; i++) {
      int newIndex = (i + n) % size;
      shiftedArray[newIndex] = array[i];
    }

    return shiftedArray;
  }
}
