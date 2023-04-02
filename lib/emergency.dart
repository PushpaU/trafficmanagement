import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Emergency extends StatefulWidget {
  Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  TextEditingController messageController = TextEditingController();

  //DatabaseReference dref=FirebaseDatabase.instance.ref("message");
  final dataref = FirebaseDatabase.instance.ref();

  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Emergency Message"),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: messageController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blueAccent,
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50)),
                    labelText: "Enter the warning message",
                    errorText: _validate ? 'Value Can\'t Be Empty' : null,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                      messageController.text.isEmpty ? _validate = true : _validate = false;
                    });
                print(messageController.text);
                dataref.child('messages').set({'msg': messageController.text});
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload warning"),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton.icon(
              onPressed: () {
                print(messageController.text);
                dataref.child('messages').remove();
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload warning"),
            )
          ],
        )));
  }
}
