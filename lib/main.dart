import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icon/gen2.png'), // App icon here
                  const SizedBox(height: 20), // Space between icon and text
                  const Text(
                    'Malawi Geocoder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between title and slogan
                  const Text(
                    'Your reliable Malawian geocoding companion',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const MyHomePage();
        }
      },
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate a delay
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog(context);
        prefs.setBool('isFirstLaunch', false);
      });
    }
  }

  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome to Malawi Geocoder'),
          content: const Text(
            'We are glad to have you! Malawi Geocoder helps you find '
                'accurate geocoding information for addresses in Malawi. '
                'Get started by entering an address in the search bar.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
