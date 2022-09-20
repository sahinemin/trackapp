import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackapp/providers/location_provider.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        return const Center(
            child: Text(
          'Your location is tracking ...',
        ));
      },
      future: Provider.of<LocationProvider>(
        context,
      ).getLocationChanges(),
    );
  }
}
