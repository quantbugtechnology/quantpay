import 'package:flutter/material.dart';
import 'package:quantupi/quantupi.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String data = 'Testing plugin';

  @override
  void initState() {
    super.initState();
  }

  Future<String> initiateTransaction(String app) async {
    Quantupi upi = Quantupi(
      receiverUpiId: 'merchant737120.augp@aubank',
      receiverName: 'Tester',
      transactionRefId: 'TestingId',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.0,
    );

    String response = await upi.startTransaction();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  initiateTransaction("merchant737120.augp@aubank")
                      .then((onValue) {
                    setState(() {
                      data = onValue;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "Tap to pay",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                data,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }
}
