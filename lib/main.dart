import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_front/features/auth/views/splash.view.dart';
import 'package:flutter_front/features/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Supabase.initialize(
    url: 'https://rfemjjpposrlnzinhero.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmZW1qanBwb3NybG56aW5oZXJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA3NzI0MzYsImV4cCI6MjA4NjM0ODQzNn0.O7lZqIchFhOgPlMnydcKFnoXaw7twm0DpoXTGc99ehk',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAPPOSTING',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      home: const SplashView(),
    );
  }
}