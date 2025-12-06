import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class AppCheckDebugPage extends StatefulWidget {
  const AppCheckDebugPage({super.key});

  @override
  State<AppCheckDebugPage> createState() => _AppCheckDebugPageState();
}

class _AppCheckDebugPageState extends State<AppCheckDebugPage> {
  String? _token;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Some versions of the plugin accept a positional `forceRefresh` boolean.
      // Call it positionally to remain compatible across versions.
      final result = await FirebaseAppCheck.instance.getToken(forceRefresh);
      // `result` may be a string or an object with `.token`. Use dynamic access safely.
      String tokenString;
      if (result is String) {
        tokenString = result;
      } else {
        tokenString = (result as dynamic)?.token?.toString() ?? result.toString();
      }
      setState(() {
        _token = tokenString;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _copyToken() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App Check token copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Check Debug')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!kDebugMode) ...[
              Text('This debug page is intended for debug builds only.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              SizedBox(height: 12.h),
            ],
            ElevatedButton.icon(
              onPressed: _loading ? null : () => _fetchToken(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(_loading ? 'Refreshing...' : 'Refresh token', style: TextStyle(fontSize: 14.sp)),
            ),
            SizedBox(height: 12.h),
            SelectableText('Token (copy and paste into Firebase Console → App Check → Debug tokens):', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey.shade50,
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Text('Error: $_error', style: TextStyle(color: Colors.red, fontSize: 14.sp))
                      : SelectableText(_token ?? 'No token available. Try Refresh.', style: TextStyle(fontSize: 14.sp)),
            ),
            SizedBox(height: 12.h),
            Row(children: [
              ElevatedButton(
                onPressed: (_token == null) ? null : _copyToken,
                child: Text('Copy token', style: TextStyle(fontSize: 14.sp)),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: () => _fetchToken(forceRefresh: false),
                child: Text('Reload (cached)', style: TextStyle(fontSize: 14.sp)),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
