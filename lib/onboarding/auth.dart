import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terrain/onboarding/welcome.dart';
import 'package:terrain/pages/personal_library.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = supabase.auth.currentSession;

        if (session != null) {
          return MyPersonalLibrary();
        } else {
          return const Welcome();
        }
      },
    );
  }
}
