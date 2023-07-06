import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:vibration/vibration.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<StepCount> _stepCountSubscription;
  late StreamSubscription<PedestrianStatus> _pedestrianStatusSubscription;
  int _startSteps = 0;
  String _status = '?';
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    startCountingSteps();

  }

  void startCountingSteps() {
    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream
        .listen(onPedestrianStatusChanged, onError: onPedestrianStatusError);

    _stepCountSubscription = Pedometer.stepCountStream
        .listen(onStepCount, onError: onStepCountError);
  }

  void stopCountingSteps() {
    _stepCountSubscription.cancel();
    _pedestrianStatusSubscription.cancel();
  }

  void onStepCount(StepCount event) {
    if (_startSteps == 0) {
      _startSteps = event.steps;
    }
    setState(() {
      _steps = event.steps - _startSteps;
      if (_steps % 100 == 0 && _steps != 0) {
        Vibration.vibrate(duration: 1000);
        AudioPlayer().play(AssetSource("blingbling.mp3"));
      }
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 0;
    });
  }

  void resetSteps() {
    setState(() {
      _steps = 0;
      _startSteps = 0;
    });
  }

  @override
  void dispose() {
    stopCountingSteps();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Your Daily Steps'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Steps Taken',
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  _steps.toString(),
                  style: TextStyle(fontSize: 60),
                ),
                ElevatedButton(
                  onPressed: resetSteps,
                  child: Text(
                    'Restart',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 100),
                Divider(
                  height: 0,
                  thickness: 0,
                  color: Colors.white,
                ),
                SizedBox(height: 100),
                Text(
                  'Pedestrian Status',
                  style: TextStyle(fontSize: 30),
                ),
                Icon(
                  _status == 'walking'
                      ? Icons.directions_walk
                      : _status == 'stopped'
                      ? Icons.accessibility_new
                      : Icons.error,
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
