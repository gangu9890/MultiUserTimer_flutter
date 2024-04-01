import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(App());
}

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  TextEditingController _userNameController = TextEditingController();
  List<TimerModel> timers = [];
  int counter = 1;
  void addTimer() {
    String userName = _userNameController.text;
    if (userName.isNotEmpty) {
      TimerModel timer = TimerModel(userName, timers.length + 1,
          removeTimer); 
      timers.add(timer);
      setState(() {});
      _userNameController.text = '';
    }
  }
  void removeTimer(TimerModel timer) {
    int index = timers.indexOf(timer);
    timers.removeAt(index);
    for (int i = index; i < timers.length; i++) {
      timers[i].serialNumber--;
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bouncy Timer'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF262329),
              Color(0xFFDB14FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                          hintText: '   Enter User Name',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 211, 211, 211))),
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: addTimer,
                  child: Text('Add Timer'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timers.length,
                itemBuilder: (context, index) {
                  return timers[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerModel extends StatefulWidget {
  final String userName;
  int serialNumber;
  final Function(TimerModel) removeCallback;
  TimerModel(this.userName, this.serialNumber, this.removeCallback);
  @override
  _TimerModelState createState() => _TimerModelState();
}

class _TimerModelState extends State<TimerModel>
    with AutomaticKeepAliveClientMixin {
  int secondsRemaining = 1200;
  bool paused = false;
  Timer? _timer;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
  }
  void startTimer() {
    if (_timer == null) {
      setState(() {
        paused = false;
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (!paused && secondsRemaining > 0) {
            setState(() {
              secondsRemaining--;
            });
          } else if (secondsRemaining == 0) {
            _timer?.cancel();
            _timer = null;
            _playHapticFeedback();
          }
        });
      });
    }
  }
  void pauseTimer() {
    setState(() {
      paused = true;
      _timer?.cancel();
      _timer = null;
    });
  }
  void _playHapticFeedback() {
    HapticFeedback.vibrate();
    setState(() {
      secondsRemaining = 0; // Set secondsRemaining to 0 to trigger UI update
    });
  }
  void deleteTimer() {
    widget.removeCallback(widget);
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.serialNumber}. ${widget.userName}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '$minutes:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        secondsRemaining == 0 // Check if the timer has run out
            ? Center(
                child: Text(
                  "Time's Up",
                  style: TextStyle(
                      color: Color.fromRGBO(223, 255, 215, 1), fontSize: 12),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: startTimer,
                    child: Text('Start'),
                  ),
                  SizedBox(width: 10), // Add some spacing between buttons
                  ElevatedButton(
                    onPressed: pauseTimer,
                    child: Text('Pause'),
                  ),
                  SizedBox(width: 10), // Add some spacing between buttons
                  ElevatedButton(
                    onPressed: deleteTimer,
                    child: Text('Delete'),
                  ),
                ],
              ),
      ],
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncy App',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      home: TimerWidget(),
    );
  }
  MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;
    for (int strength in strengths) {
      swatch[strength] = Color.fromRGBO(r, g, b, 1);
    }
    return MaterialColor(color.value, swatch);
  }
}
