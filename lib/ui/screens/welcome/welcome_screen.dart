import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Expanded(
                flex: 8,
                child: Image.asset(
                  AssetsPath.welcomeImage,
                ),
              ),
              const Spacer(flex: 3),
              Text(
                Str.welcomeMessage1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
              ),
              const Spacer(),
              Text(
                Str.welcomeMessage2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.7)),
              ),
              const Spacer(flex: 2),
              FittedBox(
                child: TextButton(
                  onPressed: () {
                    Hive.box(BoxNames.settings).put('is-skipped', true);
                    Navigator.pushNamed(
                      context,
                      RouteNames.signInOrSignUpScreen,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "Skip",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.8),
                            ),
                      ),
                      const SizedBox(width: kDefaultPadding / 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.8),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
