import 'package:flutter/material.dart';

import '../../../constants.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(
=======
      padding: EdgeInsets.symmetric(
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
<<<<<<< HEAD
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
=======
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
<<<<<<< HEAD
            const Icon(Icons.mic, color: kPrimaryColor),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
=======
            Icon(Icons.mic, color: kPrimaryColor),
            SizedBox(width: kDefaultPadding),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
                          .withOpacity(0.64),
                    ),
<<<<<<< HEAD
                    const SizedBox(width: kDefaultPadding / 4),
                    const Expanded(
=======
                    SizedBox(width: kDefaultPadding / 4),
                    Expanded(
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Type message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.attach_file,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
                          .withOpacity(0.64),
                    ),
<<<<<<< HEAD
                    const SizedBox(width: kDefaultPadding / 4),
=======
                    SizedBox(width: kDefaultPadding / 4),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
                          .withOpacity(0.64),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
