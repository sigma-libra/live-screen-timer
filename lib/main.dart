import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

const _channel = MethodChannel('live_screen_timer/service');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Screen Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.orange,
          secondary: AppColors.gold,
          error: AppColors.red,
          surface: AppColors.dark,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
      ),
      home: const PermissionScreen(),
    );
  }
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _permissionGranted = false;
  bool _serviceStarted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _channel.invokeMethod<bool>('checkNotificationPermission') ?? false;
    setState(() => _permissionGranted = granted);
    if (granted) await _startService();
  }

  Future<void> _requestPermission() async {
    final granted = await _channel.invokeMethod<bool>('requestNotificationPermission') ?? false;
    setState(() => _permissionGranted = granted);
    if (granted) await _startService();
  }

  Future<void> _startService() async {
    await _channel.invokeMethod('startService');
    setState(() => _serviceStarted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Live Screen Timer', style: TextStyle(color: AppColors.orange)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 80, color: AppColors.orange),
              const SizedBox(height: 24),
              const Text(
                'Screen Time Tracker',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Shows a notification counting how long your screen has been on since the last unlock.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (!_permissionGranted) ...[
                const Text(
                  'Notification permission is required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Grant Notification Permission'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else if (_serviceStarted) ...[
                const Icon(Icons.check_circle, color: AppColors.gold, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Timer is running!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your notification bar. It resets every time you unlock your screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
