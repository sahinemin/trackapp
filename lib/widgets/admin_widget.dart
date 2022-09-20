import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/user_location.dart';
import '../providers/authentication.dart';

class AdminWidget extends StatelessWidget {
  const AdminWidget({super.key});
  void _navigate(BuildContext context, Map<String, dynamic> info) {
    Navigator.of(context).pushNamed(UserLocation.routeName, arguments: info);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: FutureBuilder<List>(
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(8),
                      child: Card(
                        color: Colors.white,
                        elevation: 6,
                        child: InkWell(
                          onTap: () =>
                              _navigate(context, snapshot.data![index]),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(snapshot.data![index]['email']),
                            subtitle: Text(snapshot.data![index]['userId']),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const Center(
                child: Text(
              "error",
              style: TextStyle(fontSize: 48),
            ));
          },
          future: Provider.of<Auth>(context, listen: false).getAllUsers()),
    );
  }
}
