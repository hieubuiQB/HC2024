import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food/admin/admin_home.dart';
import 'package:food/admin/admin_login.dart';
import 'package:food/app/screens/auth/login_screen.dart';
import 'package:food/app/screens/home/home_screen.dart';
import 'package:food/app/screens/splash/splash_screen.dart';

import 'app/widgets/bottomnavbar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home:BotomNavBar(),
    );
  }
}