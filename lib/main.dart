import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hangman/screens/Splash_Screen1.dart';
import 'package:flutter_hangman/screens/home_screen.dart';
import 'package:flutter_hangman/screens/score_screen.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔄 Initializing Firebase...");

  if (Firebase.apps.isEmpty) {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyCkaerJ_lYP7ubFk1SQf2jvjuDdAXyC2Ak',
            appId: '1:568972077157:web:fa0babb05765507cc1be8c',
            messagingSenderId: "568972077157",
            authDomain: "wordscue-f227f.firebaseapp.com",
            databaseURL: "https://wordscue-f227f-default-rtdb.firebaseio.com",
            projectId: "wordscue-f227f",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      print("✅ Firebase initialized");
    } catch (e) {
      print("❌ Firebase error: $e");
    }
  }

  print("🚀 Running app...");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),

      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF421b9b),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'PatrickHand'),
      ),
      // initialRoute: 'homePage',
      // routes: {
      //   'homePage': (context) => HomeScreen(),
      //   'scorePage': (context) => const ScoreScreen(),
      // },
    );
  }
}
