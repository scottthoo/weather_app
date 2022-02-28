import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/home_page.dart';
import 'package:weather_app/providers/forecast_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/landing_page.dart';
import 'package:weather_app/screens/other_page.dart';
import 'package:weather_app/utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider.value(
        value: WeatherChangeNotifier(),
      ),
      ChangeNotifierProvider.value(
        value: ForecastChangeNotifier(),
      ),
    ], child: const MyApp()),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: LandingPage(),
      ),
    );
  }
}
