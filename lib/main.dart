import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ui/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).then(
          (_) => runApp(MyApplication()));
}

class MyApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TheMealDB',
        debugShowCheckedModeBanner: false,
        home: HomeScreen());
  }
}