import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'ScreenTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.orange,
          surface: AppColors.dark,
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      home: const ScreenTimeHome(),
    );
  }
}

class ScreenTimeHome extends StatefulWidget {
  const ScreenTimeHome({super.key});

  @override
  State<ScreenTimeHome> createState() => _ScreenTimeHomeState();
}

class _ScreenTimeHomeState extends State<ScreenTimeHome>
    with SingleTickerProviderStateMixin {
  bool _serviceStarted = false;
  bool _batteryOptimizationDisabled = false;
  bool _timerVisible = false;
  DateTime? _sessionStart;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  // Drives the live indicator dot: fades in and out on a 2s loop
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _checkPermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final granted =
        await _channel.invokeMethod<bool>('checkNotificationPermission') ??
            false;
    if (granted) await _startService();
  }

  Future<void> _requestPermission() async {
    final granted =
        await _channel.invokeMethod<bool>('requestNotificationPermission') ??
            false;
    if (granted) await _startService();
  }

  Future<void> _startService() async {
    await _channel.invokeMethod('startService');
    final batteryOk =
        await _channel.invokeMethod<bool>('isBatteryOptimizationDisabled') ??
            false;
    _sessionStart = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_sessionStart!));
    });
    setState(() {
      _serviceStarted = true;
      _batteryOptimizationDisabled = batteryOk;
    });
    // Let the running screen mount, then slide the timer in
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) setState(() => _timerVisible = true);
  }

  Future<void> _requestDisableBatteryOptimization() async {
    await _channel.invokeMethod('requestDisableBatteryOptimization');
    await Future.delayed(const Duration(seconds: 1));
    final batteryOk =
        await _channel.invokeMethod<bool>('isBatteryOptimizationDisabled') ??
            false;
    setState(() => _batteryOptimizationDisabled = batteryOk);
  }

  String get _timerText {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60);
    final s = _elapsed.inSeconds.remainder(60);
    return '${h}h ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        // Fades between setup and running — the "activation" moment
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _serviceStarted
              ? _buildRunning(key: const ValueKey('running'))
              : _buildSetup(key: const ValueKey('setup')),
        ),
      ),
    );
  }

  Widget _buildSetup({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text(
            'ScreenTime',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Counts how long your screen has been on since your last unlock, shown as a persistent notification.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Allow Notifications',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRunning({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text(
            'ScreenTime',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle row with live indicator dot
          Row(
            children: [
              Text(
                'Resets each time you unlock',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: AppColors.orange,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 72),
          // Timer slides up and fades in on first appearance
          AnimatedOpacity(
            opacity: _timerVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _timerVisible ? Offset.zero : const Offset(0, 0.04),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  _timerText,
                  style: GoogleFonts.spaceMono(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'NOTIFICATION PREVIEW',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildNotificationPreview(),
          const Spacer(),
          if (!_batteryOptimizationDisabled) _buildBatteryRow(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotificationPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0x26FF6B00),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined,
                color: AppColors.orange, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ScreenTime',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCCBBAA),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timerText,
                  style: GoogleFonts.spaceMono(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryRow() {
    return Row(
      children: [
        const Icon(Icons.battery_saver_outlined,
            color: AppColors.muted, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Android may pause the timer to save battery.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _requestDisableBatteryOptimization,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Keep running',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
