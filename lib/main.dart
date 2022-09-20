import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackapp/pages/splash_screen.dart';
import 'package:trackapp/pages/user_location.dart';
import 'package:trackapp/providers/authentication.dart';
import 'providers/location_provider.dart';
import 'pages/homepage.dart';
import 'pages/auth_screen.dart';
/*
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    /*
          Geolocator.getCurrentPosition().then((position) async {
            //print(position.toString());
            await Provider.of<LocationProvider>(context, listen: false)
                .postLocation(LocationData(id: "3", position: position));
          });*/
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        Provider(
            create: (context) async =>
                await Provider.of<LocationProvider>(context, listen: false)
                    .postLocation(LocationData(position: position)));
      }
    });
    return Future.value(true);
  });
}*/

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  /*Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );*/
  //Workmanager().registerOneOffTask("task-identifier", "simpleTask");

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Auth()),
    ChangeNotifierProxyProvider<Auth, LocationProvider>(
      create: (context) => LocationProvider("", "", []),
      update: (context, value, previous) =>
          LocationProvider(value.token, value.userId, previous!.locations),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: 'TrackApp',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.grey,
          error: Colors.red,
        ),
      ),
      home: FutureBuilder<bool>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              if (snapshot.data!) {
                return const HomePage();
              } else {
                return const AuthScreen();
              }
            }
          }
          return const SplashScreen();
        },
        future: Provider.of<Auth>(context, listen: false).tryAutoLogin(),
      ),
      routes: {
        HomePage.routeName: (_) => const HomePage(),
        AuthScreen.routeName: (_) => const AuthScreen(),
        UserLocation.routeName: (_) => const UserLocation()
      },
    );
  }
}
