import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackapp/providers/location_provider.dart';
import '../providers/authentication.dart';
import 'auth_screen.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/homepage';
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('TrackApp')),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          return const Center(
              child: Text(
            'Your location is tracking ...',
          ));
        },
        future: Provider.of<LocationProvider>(context).getLocationChanges(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Provider.of<Auth>(context, listen: false).logOut().then((_) {
            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
