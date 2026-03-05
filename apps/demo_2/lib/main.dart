import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

void main() {
  runApp(const DemoTwoApp());
}

class DemoTwoApp extends StatelessWidget {
  const DemoTwoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _DemoTwoHomePage(),
    );
  }
}

class _DemoTwoHomePage extends StatefulWidget {
  const _DemoTwoHomePage();

  @override
  State<_DemoTwoHomePage> createState() => _DemoTwoHomePageState();
}

class _DemoTwoHomePageState extends State<_DemoTwoHomePage> {
  String _message = '';
  int count =0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo 2 App')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'Show Message',
              onPressed: () {
                setState(() {
                  _message = 'Hello from Demo 2 app';
                   count ++;
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Center(child: Text(_message,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),
                 SizedBox(height: 12,),
                 Text(count.toString(),
                 style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                 ),)
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
