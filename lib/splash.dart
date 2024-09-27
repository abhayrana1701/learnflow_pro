import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "home.dart";
import "signin.dart";

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  Future<bool> checkSignInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSignedIn = prefs.getBool('isSignedIn') ?? false;
    return isSignedIn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Use FutureBuilder to asynchronously get the user's sign-in status
      future: checkSignInStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.data == true) {
          // User is signed in
          return Home();
        } else {
          // User is not signed in
          return Signin();
        }
      },
    );
  }
}
