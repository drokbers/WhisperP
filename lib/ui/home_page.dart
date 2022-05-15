import 'package:flutter/material.dart';

import '../consts/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Str.homePageTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
