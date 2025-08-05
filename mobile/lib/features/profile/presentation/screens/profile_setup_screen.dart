import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mandatory Profile Setup (Screen 25)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement profile update logic (PUT /users/me)
                // This should update the user data in the repository, which triggers an AuthBloc update,
                // causing GoRouter to automatically redirect to the dashboard.
              },
              child: const Text('Complete Setup (Mock)'),
            ),
          ],
        ),
      ),
    );
  }
}