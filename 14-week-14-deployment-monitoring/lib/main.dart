import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

bool _firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firebaseReady = true;
    debugPrint('[Firebase] Core ready ✓');
  } catch (e) {
    debugPrint('[Firebase] init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deployment Monitoring Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Deployment Monitoring Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _status = '';

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
      _status = '';
    });

    if (!_firebaseReady) return;

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'beta_feedback_sent',
        parameters: {'screen_name': 'home'},
      );
      debugPrint('[Analytics] beta_feedback_sent ✓');
      setState(() => _status = 'Analytics: beta_feedback_sent ✓');
    } catch (e) {
      debugPrint('[Analytics] failed: $e');
      setState(() => _status = 'Analytics error: $e');
    }
  }

  // Simulate a non-fatal error report (Crashlytics requires console activation
  // before native component works; logged locally as documented alternative)
  void _sendTestCrash() {
    final err = Exception('Synthetic non-fatal test error — beta verification');
    final stack = StackTrace.current;
    debugPrint('[Crashlytics-sim] recordError: $err\n$stack');
    setState(
      () => _status =
          'Crashlytics: non-fatal error logged locally\n'
          '(see release-report.md §6 for activation limitation)',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _firebaseReady ? Icons.cloud_done : Icons.cloud_off,
                  size: 14,
                  color: _firebaseReady ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _firebaseReady
                      ? 'Firebase connected ✓'
                      : 'Firebase not connected',
                  style: TextStyle(
                    fontSize: 12,
                    color: _firebaseReady ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _sendTestCrash,
              icon: const Icon(Icons.bug_report),
              label: const Text('Send test crash to Crashlytics'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment & log Analytics',
        child: const Icon(Icons.add),
      ),
    );
  }
}
