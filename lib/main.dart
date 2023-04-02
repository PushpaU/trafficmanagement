import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:trafficmanagement/emergency.dart';
import './signalTiming.dart';

// void main() {
//   runApp(
//       const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDTUkjF2yn5HKQB-DTWDbELhuj52zQ-qHE",
          authDomain: "complex-15e3e.firebaseapp.com",
          databaseURL: "https://complex-15e3e-default-rtdb.firebaseio.com/",
          projectId: "complex-15e3e",
          storageBucket: "complex-15e3e.appspot.com",
          messagingSenderId: "440834574267",
          appId: "1:440834574267:web:9087033036a44bb9ea669e"));
  runApp(const MaterialApp(home: HomePage(),
  debugShowCheckedModeBanner: false,));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<FirebaseApp> _fapp = Firebase.initializeApp();
  var vehicleCount;
  int normalVehicleCount = 5;
  var speedLimit = 60;
  String ?allertMessage;

  final CountdownController _controller = CountdownController(autoStart: true);

  void calculateSpeedLimit(int vcount) {
    if (vcount > normalVehicleCount && vcount <= normalVehicleCount + 5) {
      speedLimit = speedLimit - 10;
    } else if (vcount > normalVehicleCount + 5 &&
        vcount <= normalVehicleCount + 10) {
      speedLimit = speedLimit - 20;
    } else if (vcount > normalVehicleCount + 15) {
      speedLimit = speedLimit - 30;
    } else {
      speedLimit = 60;
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference _dbref =
        FirebaseDatabase.instance.ref().child('vehicles').child('incount');
    _dbref.onValue.listen((event) {
      setState(() {
        vehicleCount = event.snapshot.value;
        calculateSpeedLimit(vehicleCount);

        print(vehicleCount);
        print(speedLimit);
      });
    });

    DatabaseReference _allert =
        FirebaseDatabase.instance.ref().child('messages').child('msg');
    _allert.onValue.listen((event) {
      setState(() {
        allertMessage = event.snapshot.value.toString();
        calculateSpeedLimit(vehicleCount);

        print(allertMessage);
      });
    });
  }

  void newState() {
    setState(() {
      _controller.restart();
    });
  }

  Widget warningCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            child: Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vehicle count : $vehicleCount",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text("Speed Limit :$speedLimit",
                        style: const TextStyle(fontSize: 30)),
                    const SizedBox(
                      height: 20,
                    ),
                    if (allertMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          allertMessage!,
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ] else ...[
                      SizedBox(height: 10),
                    ]
                  ],
                )),
          ),
          const SizedBox(
            height: 50,
          ),
          Countdown(
            controller: _controller,
            seconds: 3,
            build: (_, double time) => Text(
              time.toString(),
              style: const TextStyle(
                fontSize: 80,
              ),
            ),
            interval: const Duration(milliseconds: 300),
            onFinished: () {
              DatabaseReference _dbref = FirebaseDatabase.instance
                  .ref()
                  .child('vehicles')
                  .child('incount');
              _dbref.onValue.listen((event) {
                setState(() {
                  vehicleCount = event.snapshot.value.toString();
                  print(vehicleCount);
                });
              });
              newState();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Timer is done!'),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Pause'),
                onPressed: () {
                  _controller.pause();
                },
              ),
              ElevatedButton(
                child: const Text('Resume'),
                onPressed: () {
                  _controller.resume();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Emergency()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Accident Zone'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignalTiming()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Signal Count Down'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Limit"),
      ),
      body: FutureBuilder(
          future: _fapp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something wrong in firebase");
            } else if (snapshot.hasData) {
              return warningCard();
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
