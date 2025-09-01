import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/utils/greetings.dart';
import 'package:flutter/material.dart';

class Greetings extends StatelessWidget {
  final String firstName;
  final String profilePictureUrl;
  const Greetings({
    super.key,
    required this.firstName,
    required this.profilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: Card(
        elevation: 8, // Increased elevation for a more pronounced shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),

        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 30.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getGreeting()}, $firstName!',
                    style: TextStyle(fontSize: FontSizes().h3, fontWeight: FontWeight.bold),
                  ),
                  Text('Welcome to the Enforcer Auto Fine App.'),
                ],
              ),
              const Spacer(),

              CircleAvatar(
                radius: 25, // radius is half the desired width/height
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : null,
                child: profilePictureUrl.isEmpty
                    ? Icon(Icons.account_circle, size: 50)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
