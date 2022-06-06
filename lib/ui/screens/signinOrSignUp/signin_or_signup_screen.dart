import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/components/primary_button.dart';
import 'package:whisperp/ui/constants.dart';
import 'package:flutter/material.dart';

class SigninOrSignupScreen extends StatelessWidget {
  const SigninOrSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                "assets/images/whisper-logo.png",
                height: 146,
              ),
              const Spacer(),
              PrimaryButton(
                text: "Sign In",
                press: () => Navigator.pushNamed(context, RouteNames.signIn),
              ),
              const SizedBox(height: kDefaultPadding * 1.5),
              PrimaryButton(
                color: Theme.of(context).colorScheme.secondary,
                text: "Sign Up",
                press: () => Navigator.pushNamed(context, RouteNames.register),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
