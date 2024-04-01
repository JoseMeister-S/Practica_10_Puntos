import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool useFingerprint = false; // Initial value for the switch
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        useFingerprint = prefs.getBool('useFingerPrint') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use Fingerprint',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: useFingerprint,
              onChanged: (newValue) async {
                setState(() {
                  useFingerprint = newValue;
                });
                final SharedPreferences prefs = await _prefs;
                await prefs.setBool('useFingerPrint', newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}
