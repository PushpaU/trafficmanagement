import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class SignalTiming extends StatefulWidget {
  const SignalTiming({super.key});

  @override
  State<SignalTiming> createState() => _SignalTimingState();
}

class _SignalTimingState extends State<SignalTiming> {
  final Future<FirebaseApp> _fapp = Firebase.initializeApp();
  var vehicleCountRoad1;
  var vehicleCountRoad2;
  int totalVehicleCount = 0;
  int counter1 = 0;
  int counter2 = 0;
  int onrLoopDuration = 20; // each  signal for 10s;
  int count = 0;
  bool _isLoading1 = false;
  bool _isLoading2 = false;

  //  var vehicleCount ;
  // int normalVehicleCount = 5;
  // var speedLimit = 60;

  final CountdownController _controller = CountdownController(autoStart: true);

  void calculateCounter(int vcount1, int vcount2) {
    totalVehicleCount = vcount1 + vcount2;
    counter1 = (vcount2 / totalVehicleCount) * 20 as int;
    counter2 = (vcount1 / totalVehicleCount) * 20 as int;
    _isLoading1 = true;

    Timer(Duration(seconds: counter1), () {
      setState(() {
        //_isLoading1 = false;
        _isLoading2 = true;

        print(_isLoading1);
        print(_isLoading2);
      });
    });

    print(totalVehicleCount);
    print(counter1);
    print(counter2);
  }

  @override
  void initState() {
    super.initState();

    DatabaseReference _dbref1 =
        FirebaseDatabase.instance.ref().child('vehicles').child('incount');
    _dbref1.onValue.listen((event) {
      setState(() {
        vehicleCountRoad1 = event.snapshot.value;
        print(vehicleCountRoad1);
      });
    });

    DatabaseReference _dbref2 =
        FirebaseDatabase.instance.ref().child('vehicles1').child('incount');
    _dbref2.onValue.listen((event) {
      setState(() {
        vehicleCountRoad2 = event.snapshot.value;
        print(vehicleCountRoad2);
        calculateCounter(vehicleCountRoad1, vehicleCountRoad2);
      });
    });
  }

  void reStartCount() {
    _isLoading1 = false;
    _isLoading2 = false;
    DatabaseReference _dbref1 =
        FirebaseDatabase.instance.ref().child('vehicles').child('incount');
    _dbref1.onValue.listen((event) {
      setState(() {
        vehicleCountRoad1 = event.snapshot.value;
        print(vehicleCountRoad1);
      });
    });

    DatabaseReference _dbref2 =
        FirebaseDatabase.instance.ref().child('vehicles1').child('incount');
    _dbref2.onValue.listen((event) {
      setState(() {
        vehicleCountRoad2 = event.snapshot.value;
        print(vehicleCountRoad2);
        calculateCounter(vehicleCountRoad1, vehicleCountRoad2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Time Limit of the Signals")),
      body: FutureBuilder(
          future: _fapp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something wrong in firebase");
            } else if (snapshot.hasData) {
              return totalVehicleCount != 0
                  ? timerCard(counter1, counter2)
                  : const CircularProgressIndicator();
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }

  Widget timerCard(int count1, int count2) {
    print("count");
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(200, 0, 0, 0),
          child: Container(
            width: 100,
            height: 1200,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 250, 0, 0),
          child: Container(
            width: 1200,
            height: 100,
            color: Colors.black,
          ),
        ),
        if (_isLoading1) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(210, 150, 0, 0), //Top
            child: Container(
                width: 80,
                height: 80,
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Count: $vehicleCountRoad1",
                        style: const TextStyle(fontSize: 12),
                      ),
                      countDown(counter1),
                    ],
                  ),
                )),
          ),
        ],
        if (_isLoading2) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(210, 360, 0, 0), //Bottom
            child: Container(
                width: 80,
                height: 80,
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Count: $vehicleCountRoad2",
                          style: const TextStyle(fontSize: 12)),
                      countDown(counter2),
                    ],
                  ),
                )),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(100, 260, 0, 0), // Left
          child: Container(
            width: 80,
            height: 80,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(315, 260, 0, 0), //Right
          child: Container(
            width: 80,
            height: 80,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget countDown(int s) {
    return Countdown(
      controller: _controller,
      seconds: s,
      build: (_, double time) => Text(
        "Time : $time",
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      interval: const Duration(milliseconds: 100),
      onFinished: () {
        count = count + 1;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("$count signal is finished"),
        //   ),
        // );
        print("finished signal $count");


        if (count == 2) {
          count = 0;
          print("restarted");
          setState(() {
            //_isLoading2 = false;
            reStartCount();
          });
        }

        // newState();

        // );
      },
    );
  }
}
