import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:terrain/onboarding/auth.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ouviykauwyznlangbuxp.supabase.co',
    publishableKey: 'sb_publishable_mIAEJB4vI9bWA2r8epQfbg_Mgg1IG5_'
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

