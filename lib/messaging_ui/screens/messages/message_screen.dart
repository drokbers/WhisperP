import 'package:whisperp/messaging_ui/constants.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class MessagesScreen extends StatelessWidget {
<<<<<<< HEAD
  const MessagesScreen({Key? key}) : super(key: key);

=======
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
<<<<<<< HEAD
      body: const Body(),
=======
      body: Body(),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
<<<<<<< HEAD
          const BackButton(),
          const CircleAvatar(
            backgroundImage: AssetImage("assets/images/user_2.png"),
          ),
          const SizedBox(width: kDefaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
=======
          BackButton(),
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/user_2.png"),
          ),
          SizedBox(width: kDefaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
              Text(
                "Kristin Watson",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Active 3m ago",
                style: TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
      actions: [
        IconButton(
<<<<<<< HEAD
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
        const SizedBox(width: kDefaultPadding / 2),
=======
          icon: Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.videocam),
          onPressed: () {},
        ),
        SizedBox(width: kDefaultPadding / 2),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
      ],
    );
  }
}
