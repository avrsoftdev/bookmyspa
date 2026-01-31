import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionBannerWidget extends StatefulWidget {
  const PermissionBannerWidget({super.key});

  @override
  State<PermissionBannerWidget> createState() => _PermissionBannerWidgetState();
}

class _PermissionBannerWidgetState extends State<PermissionBannerWidget>
    with WidgetsBindingObserver {
  bool _dismissed = false;
  bool _shouldShow = false;
  String _message = '';
  String _actionLabel = '';
  bool _notifDenied = false;
  bool _locDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _evaluate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    final notifStatus = await Permission.notification.status;
    final locPerm = await Geolocator.checkPermission();

    _notifDenied = !notifStatus.isGranted;
    _locDenied =
        locPerm == LocationPermission.denied ||
        locPerm == LocationPermission.deniedForever;

    String msg = '';
    String action = '';
    if (_notifDenied && _locDenied) {
      msg =
          'Allow location and notifications to find nearby spas and receive booking updates.';
      action = 'Enable Now';
    } else if (_locDenied) {
      msg = 'Allow location access to find nearby spas and services easily.';
      action = 'Enable Location';
    } else if (_notifDenied) {
      msg =
          'Turn on notifications to get booking updates and important alerts.';
      action = 'Enable Now';
    }

    setState(() {
      _shouldShow = msg.isNotEmpty;
      _message = msg;
      _actionLabel = action;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    await _evaluate();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || !_shouldShow) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _openSettings,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.security_rounded, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openSettings,
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(
                    _actionLabel.isEmpty ? 'Enable Now' : _actionLabel,
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _dismissed = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close_rounded, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
