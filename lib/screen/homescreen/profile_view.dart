import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eentrack/screen/homescreen/home_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_avatar/random_avatar.dart';

import '../authscreens/shared/customcontainer.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
  });

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<HomeScreenVM>().user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Animate(
        effects: const [ShimmerEffect()],
        child: ListView(
          children: [
            CircleAvatar(
              radius: 60,
              child: RandomAvatar(user.name),
            ).animate().slideY().fadeIn(),
            const SizedBox(
              height: 20,
            ),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Hello ${user.name}...',
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  curve: Curves.easeInOut,
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextWidget(
              text: user.name,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextWidget(
              text: user.department,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextWidget(
                    text: user.roll,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextWidget(
                    text: user.semester,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextWidget(
              text: user.github.isEmpty ? 'Github Not Available' : user.github,
              trailing: IconButton(
                onPressed: () {
                  copyToClipboard(user.github);
                },
                icon: const Icon(Icons.copy),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextWidget(
              text: user.linkedin.isEmpty
                  ? 'LinkedIn Not Available'
                  : user.linkedin,
              trailing: IconButton(
                onPressed: () {
                  copyToClipboard(user.linkedin);
                },
                icon: const Icon(Icons.copy),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
