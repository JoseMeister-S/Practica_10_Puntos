import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:practica_10_puntos/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences _prefs;
  _SupportState supportState = _SupportState.unknown;
  LocalAuthentication localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      _prefs = prefs;
      var logged = prefs.getBool('logged') ?? false;
      var useBiometrics = prefs.getBool('useFingerPrint') ?? false;
      if (!logged) {
        return;
      }
      if (useBiometrics) {
        _checkBiometrics();
      } else {
        _navigateToHome();
      }
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
      return;
    }

    setState(() {
      supportState = canCheckBiometrics
          ? _SupportState.supported
          : _SupportState.unsupported;
    });

    if (canCheckBiometrics) {
      // You can now authenticate using biometrics
      try {
        bool authenticated = await localAuth.authenticate(
          localizedReason: 'Scan',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        print(authenticated);
        if (authenticated) {
          _navigateToHome();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    var state = _prefs.getBool('logged');
    if (state == true) {
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _onLogin(String email, String pass) async {
    if (email == "s@g.com" && pass == "pass") {
      await _prefs.setBool('logged', true);
      _navigateToHome();
    } else {
      // Handle incorrect email/password scenario
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pagina de login",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pagina de login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Check for a valid email format using a regular expression
                    bool emailValid =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value);
                    if (!emailValid) {
                      return 'Please enter a valid email';
                    }
                    return null; // Return null if the validation is successful
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null; // Return null if the validation is successful
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Validate the form before proceeding
                    if (_formKey.currentState!.validate()) {
                      await _onLogin(
                          _emailController.text, _passwordController.text);
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
