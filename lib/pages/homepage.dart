import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackapp/providers/location_provider.dart';
import '../providers/authentication.dart';
import '../widgets/admin_widget.dart';
import '../widgets/user_widget.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/homepage';
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('TrackApp')),
      ),
      body: !Provider.of<Auth>(context, listen: false).isAdmin
          ? const UserWidget()
          : const AdminWidget(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          Provider.of<Auth>(context, listen: false).logOut().then((_) {
            if (Provider.of<Auth>(context, listen: false).isAdmin) {
              SystemNavigator.pop();
            } else {
              Provider.of<LocationProvider>(context, listen: false)
                  .endStream()
                  .then((_) {
                SystemNavigator.pop();
              });
            }
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
