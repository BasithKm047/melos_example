import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _DemoHomePage(),
    );
  }
}

class _DemoHomePage extends StatefulWidget {
  const _DemoHomePage();

  @override
  State<_DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<_DemoHomePage> {
  String _message = '';
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo App')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'Show Message',
              onPressed: () {
                setState(() {
                  _message = 'Hello from Demo app';
                  count++;
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Center(
                  child: Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
